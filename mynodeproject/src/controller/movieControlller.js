import {prisma} from '../config/db.js';

const getMovie = async (req, res) => {
    const movies = await prisma.movie.findMany({
        include: {
            creator: {
                select: { id: true, name: true, email: true }
            },
        },
        orderBy: {createdAt: 'desc'},
    });

    return res.status(200).json({
        success: true,
        data: movies,
    });
}

const getMovieById = async (req, res) => {
    const { id } = req.params;

    const movie = await prisma.movie.findUnique({
        where: { id },
        include: {
            creator: { select: {id: true, name: true, email: true } },
        }
    });

    if (!movie) {
        return res.status(404).json({
            success: false,
            message: 'Movie not found'
        });
    }

    return res.status(200).json({
        success: true,
        data: movie,
    });
}

// const createMovie = async (req, res) => {
//     const {title, overview, releaseYear, genre, runtime, posterUrl, createdBy } = req.body;

//     const movie = await prisma.movie.create({
//         data: {
//             title,
//             overview,
//             releaseYear: Number(releaseYear),
//             genre: genre || [],
//             runtime: 
//         }
//     })
// }

export { getMovie , getMovieById }