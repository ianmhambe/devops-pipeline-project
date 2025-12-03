const express = require('express');
const promClient = require('prom-client');
const logger = require('./logger');

const app = express();
const PORT = process.env.PORT || 3000;

// Prometheus setup
const register = new promClient.Registry();
promClient.collectDefaultMetrics({ register });

const httpRequestCounter = new promClient.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status'],
  registers: [register]
});

// Request logging middleware
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = Date.now() - start;
    
    logger.info('HTTP Request', {
      method: req.method,
      path: req.path,
      status: res.statusCode,
      duration: duration,
      userAgent: req.get('user-agent'),
      ip: req.ip
    });
    
    httpRequestCounter.labels(req.method, req.path, res.statusCode).inc();
  });
  
  next();
});

app.get('/', (req, res) => {
  logger.info('Root endpoint accessed');
  res.json({
    message: 'Hello from DevOps Pipeline!',
    version: '2.0.0',
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  const health = {
    status: 'healthy',
    uptime: process.uptime(),
    memory: process.memoryUsage()
  };
  logger.debug('Health check', health);
  res.json(health);
});

app.get('/error', (req, res) => {
  logger.error('Test error endpoint triggered', {
    user: 'test',
    action: 'error-test'
  });
  res.status(500).json({ error: 'Test error' });
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// Error handling
app.use((err, req, res, next) => {
  logger.error('Unhandled error', {
    error: err.message,
    stack: err.stack,
    path: req.path
  });
  res.status(500).json({ error: 'Internal server error' });
});

app.listen(PORT, () => {
  logger.info(`Server started on port ${PORT}`);
});