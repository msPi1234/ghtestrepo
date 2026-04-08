const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

// Health check endpoint for Kubernetes liveness probe
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

// Readiness check endpoint for Kubernetes readiness probe
app.get('/ready', (req, res) => {
  res.status(200).json({ ready: true });
});

// Main Hello World endpoint
app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html>
      <head>
        <title>Hello World</title>
        <style>
          body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          }
          .container {
            text-align: center;
            background: white;
            padding: 50px;
            border-radius: 10px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
          }
          h1 {
            color: #667eea;
            margin: 0;
            font-size: 48px;
          }
          .info {
            color: #666;
            margin-top: 20px;
            font-size: 16px;
          }
          .pod-info {
            background: #f5f5f5;
            padding: 15px;
            border-radius: 5px;
            margin-top: 20px;
            font-family: monospace;
            text-align: left;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>Hello World! 🌍</h1>
          <div class="info">
            <p>Welcome to the AKS Kubernetes deployment</p>
            <p>Powered by Docker, Helm, and Jenkins CI/CD</p>
          </div>
          <div class="pod-info">
            <strong>Pod Information:</strong><br>
            Hostname: ${require('os').hostname()}<br>
            Environment: ${process.env.ENVIRONMENT || 'production'}<br>
            Timestamp: ${new Date().toISOString()}
          </div>
        </div>
      </body>
    </html>
  `);
});

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
  console.log(`Health check available at http://localhost:${PORT}/health`);
});
