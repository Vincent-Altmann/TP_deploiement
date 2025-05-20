const sensors = require('../data/sensors.json');

exports.getSensors = (req, res) => {
  res.json(sensors);
};

exports.getSensorById = (req, res) => {
  const sensor = sensors.find(s => s.id === parseInt(req.params.id));
  if (!sensor) {
    return res.status(404).json({ message: "Capteur non trouvé" });
  }
  res.json(sensor);
};
