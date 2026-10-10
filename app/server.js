const express = require('express');
const path = require('path');
const app = express();

// Inicialización opcional de Application Insights
if (process.env.APPLICATIONINSIGHTS_CONNECTION_STRING) {
    const appInsights = require('applicationinsights');
    appInsights.setup(process.env.APPLICATIONINSIGHTS_CONNECTION_STRING)
        .setAutoDependencyCorrelation(true)
        .setAutoCollectRequests(true)
        .setAutoCollectPerformance(true, true)
        .setAutoCollectExceptions(true)
        .setAutoCollectDependencies(true)
        .setAutoCollectConsole(true)
        .setUseDiskRetryCaching(true)
        .setSendLiveMetrics(true)
        .start();
    console.log('[Azure App Insights] Telemetría iniciada exitosamente.');
}

const PORT = process.env.PORT || 8080;

app.use(express.static(path.join(__dirname)));

app.get('/api/status', (req, res) => {
    res.json({
        status: 'UP',
        timestamp: new Date().toISOString(),
        institution: 'Universidad Tecnológica del Valle de Toluca',
        student: 'Ludwin García Gaytán',
        matricula: '222310777',
        group: 'IDGS-81',
        subject: 'Evaluación y Mejora para el Desarrollo de Software',
        practice: '12. Azure Portal - App Service (Lab 1)',
        environment: process.env.ENVIRONMENT || 'dev',
        telemetry: process.env.APPLICATIONINSIGHTS_CONNECTION_STRING ? 'ENABLED' : 'SIMULATED'
    });
});

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

app.listen(PORT, () => {
    console.log(`Servidor activo en el puerto ${PORT}`);
});
