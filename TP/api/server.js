const express = require('express');
const cors = require('cors');
const sensorRoutes = require('./routes/sensors');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());
app.use('/api/sensors', sensorRoutes);

app.get('/', (req, res) => {
  res.send('API de supervision de capteurs environnementaux');
});

app.listen(PORT, () => {
  console.log(`✅ API démarrée sur http://localhost:${PORT}`);
});
