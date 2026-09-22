import { addToWatchlist, getWatchistItem, removeFromWatchlist, updateWatchlistItem } from "../controller/watchListController.js";
import { authMiddleware } from "../middleWare/authMiddleWare.js";
import express from 'express';
import { validateRequest } from "../middleWare/validateRequest.js";
import { addWatchlistSchema } from "../validators/watchlistValidator.js";

const router = express.Router();

router.use(authMiddleware);

router.post('/',validateRequest(addWatchlistSchema) ,addToWatchlist);
router.delete('/:id', removeFromWatchlist);
router.put('/:id', updateWatchlistItem);
router.get('/', getWatchistItem);
 

export default router;

