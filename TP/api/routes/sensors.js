const express = require('express');
const router = express.Router();
const { getSensors, getSensorById } = require('../controllers/sensorsController');

router.get('/', getSensors);
router.get('/:id', getSensorById);

module.exports = router;
