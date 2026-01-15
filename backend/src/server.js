const app = require('./app');

const PORT = process.env.PORT || 3000;
const HOST = '0.0.0.0'; // Tüm network arayüzlerini dinle

app.listen(PORT, HOST, () => {
  console.log(`🚀 Server ${HOST}:${PORT} adresinde çalışıyor`);
  console.log(`📝 Local: http://localhost:${PORT}/health`);
  console.log(`📝 Network: http://192.168.1.178:${PORT}/health`);
  console.log(`🔐 API Base URL: http://localhost:${PORT}/api`);
});
