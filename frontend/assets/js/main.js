document.addEventListener("DOMContentLoaded", function() {
    let chartRatio, chartGastos;

    // 1. Cargar Datos por CSV (Módulo 1)
    const formCsv = document.getElementById('formCsv');
    if (formCsv) {
        formCsv.addEventListener('submit', function(e) {
            e.preventDefault();
            let formData = new FormData(this);
            fetch('backend/controllers/importar_csv.php', { method: 'POST', body: formData })
            .then(res => res.json())
            .then(data => {
                document.getElementById('msgCsv').innerHTML = `<div class="alert alert-success fw-bold"><i class="fa-solid fa-check-circle me-2"></i>${data.message}</div>`;
                this.reset();
            })
            .catch(err => console.error("Error importando CSV:", err));
        });
    }

    // 2. Botón Ejecutar ETL (Módulo 2)
    const btnEtl = document.getElementById('btnEtl');
    if (btnEtl) {
        btnEtl.addEventListener('click', function() {
            const originalText = this.innerHTML;
            this.innerHTML = '<i class="fa-solid fa-spinner fa-spin me-2"></i> Procesando...';
            this.disabled = true;

            fetch('backend/controllers/procesar_etl.php')
            .then(res => res.json())
            .then(data => {
                this.innerHTML = originalText;
                this.disabled = false;
                cargarGraficos(); 
                alert("Proceso ETL completado. Data Warehouse y KPIs actualizados.");
            })
            .catch(err => {
                this.innerHTML = originalText;
                this.disabled = false;
                alert("Hubo un error al ejecutar el ETL.");
            });
        });
    }

    // 3. Función para pintar gráficos de los KPIs (Chart.js)
    function cargarGraficos() {
        fetch('backend/controllers/get_kpi_data.php')
        .then(res => res.json())
        .then(data => {
            if (chartRatio) chartRatio.destroy();
            if (chartGastos) chartGastos.destroy();

            // Gráfico de Barras: Ratio de Endeudamiento
            const ctxRatio = document.getElementById('chartRatio').getContext('2d');
            chartRatio = new Chart(ctxRatio, {
                type: 'bar',
                data: {
                    labels: data.ratios.labels,
                    datasets: [{ 
                        label: '% Endeudamiento Promedio', 
                        data: data.ratios.data, 
                        backgroundColor: '#EF4444',
                        borderRadius: 5
                    }]
                },
                options: { responsive: true, scales: { y: { beginAtZero: true, max: 100 } } }
            });

            // Gráfico Doughnut: Distribución de Gastos
            const ctxGastos = document.getElementById('chartGastos').getContext('2d');
            chartGastos = new Chart(ctxGastos, {
                type: 'doughnut',
                data: {
                    labels: data.categorias.labels,
                    datasets: [{ 
                        data: data.categorias.data, 
                        backgroundColor: ['#3B82F6', '#10B981', '#F59E0B', '#6366F1', '#EC4899', '#8B5CF6', '#14B8A6', '#F43F5E'],
                        borderWidth: 0
                    }]
                },
                options: { responsive: true, cutout: '70%' }
            });
        });
    }

    // Cargar gráficos automáticamente al entrar al Módulo 2
    document.getElementById('mod2-tab').addEventListener('click', cargarGraficos);
});