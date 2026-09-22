import {z} from 'zod';

const addWatchlistSchema = z.object({
    movieId: z.string().uuid(),
    status: z.enum(
        ["PLANNED", "WATCHING", "COMPLETED", "DROPPED"],
        { error: "Status must be one of: PLANNED, WATCHING, COMPLETED, DROPPED" }
    ).optional(),
    notes: z.string().optional(),
})

export {addWatchlistSchema};