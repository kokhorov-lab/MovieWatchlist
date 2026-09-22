import express from 'express';
import { getMovie, getMovieById } from '../controller/movieControlller.js';


const router = express.Router();

router.get('/',getMovie);

router.get('/:id', getMovieById);

// router.put('/', (req, res) => {
//     res.json({httpMethod:'put'})
// });

// router.delete('/', (req, res) => {
//     res.json({httpMethod:'delete '})
// });

export default router;