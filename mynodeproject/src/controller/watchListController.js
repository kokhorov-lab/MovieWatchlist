
import { prisma } from '../config/db.js'

const addToWatchlist = async (req, res) => {
    const { movieId, status, rating, notes } = req.body; 

    const movie = await prisma.movie.findUnique({
        where: { id: movieId }
    });

    if (!movie) {
        return res.status(404).json({
            error: 'Movie not found'
        })
    }

    //Verify movie exists
    const existingInWatchlist = await prisma.watchListItem.findUnique({
        where: { userId_movieId: {
            userId: req.user.id,
            movieId: movieId,
        } 
    }
    });

    if (existingInWatchlist) {
        return res.status(401).json({
            error: 'Movie already exist in watchlist'
        });
    }

    const watchlistItem = await prisma.watchListItem.create({
        data : {
            movieId,
            userId: req.user.id,
            status: status || 'PLANNED',
            rating,
            notes,
        }
    });

    res.status(201).json({
        status: 'success',
        data: {
            watchlistItem,
        }
    })
}

const removeFromWatchlist = async (req, res) => {
    const watchlistItem = await prisma.watchListItem.findUnique({where: {id: req.params.id}});

    if(!watchlistItem){
        return res.status(401).json({
            error: 'Movie not found in watchlist'
        })
    }

    if(watchlistItem.userId !== req.user.id) {
        return res.status(403).json({error: 'Not authorize to update watchlist'})
    }

    await prisma.watchListItem.delete({
        where:{id: req.params.id}
    });

    res.status(201).json({
        status:'success',
        message: 'Movie removed from watchlist'
    });
}

const updateWatchlistItem = async (req, res) => {
    const { status, notes} = req.body;

    const watchlistItem = await prisma.watchListItem.findUnique({
        where: {id: req.params.id}
    });

    if(!watchlistItem) {
        return res.status(404).json({
            err: 'Movie not found in watchlist'
        });
    }

    if(watchlistItem.userId !== req.user.id) {
        return res.status(403).json({
            error: "User is not authorize to perform this action"
        });
    }

    const updateData = {};
    if(status !== undefined) updateData.status = status.toUpperCase();
    if(notes !== undefined) updateData.notes = notes;

    const updateItem = await prisma.watchListItem.update({
        where: {
            id: req.params.id,
        },
        data: updateData,
    })

    res.status(200).json({
        status: 'success',
        message: updateItem
    })
}

const getWatchistItem = async (req, res) => {
    try {
        const watchlistItem = await prisma.watchListItem.findMany({
            where: {
                userId: req.user.id
            },
            include: {
                movie: true,
            },
            orderBy: {
                createdAt: 'desc'
            },
        });
        const movies = watchlistItem.map((item) => item.movie);

        return res.status(200).json({
            status: 'success',
            data: movies,
        });
    }
    catch(e) {
        return res.status(500).json({
            error: e.message || 'failed to fetch movies'
        });
    }
}

export {addToWatchlist, removeFromWatchlist, updateWatchlistItem, getWatchistItem};
