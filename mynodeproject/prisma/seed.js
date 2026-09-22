import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import dotenv from 'dotenv';
import pg from 'pg';

dotenv.config();

const pool = new pg.Pool({ 
  connectionString: process.env.DATABASE_URL 
});

const adapter = new PrismaPg(pool);
const prisma = new PrismaClient({ adapter });

const userId = "7078c756-7190-4746-b71d-3249346cacdc";

// Directly hardcoded valid TMDB image paths (No API Key required)
const moviesList = [
  {
    title: "The Dark Knight",
    overview: "When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests of his ability to fight injustice.",
    releaseYear: 2008,
    genre: ["Action", "Crime", "Drama"],
    runtime: 152,
    rating: 4.9,
    posterUrl: "https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg"
  },
  {
    title: "Inception",
    overview: "A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O.",
    releaseYear: 2010,
    genre: ["Action", "Adventure", "Sci-Fi"],
    runtime: 148,
    rating: 4.8,
    posterUrl: "https://image.tmdb.org/t/p/w500/oYuLE1311oA8hL1rR212B9m2fM9.jpg"
  },
  {
    title: "Interstellar",
    overview: "When Earth becomes uninhabitable in the future, a farmer and ex-NASA pilot, Joseph Cooper, is tasked to pilot a spacecraft to find a new home.",
    releaseYear: 2014,
    genre: ["Adventure", "Drama", "Sci-Fi"],
    runtime: 169,
    rating: 4.7,
    posterUrl: "https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg"
  },
  {
    title: "Spider-Man: Into the Spider-Verse",
    overview: "Teen Miles Morales becomes the Spider-Man of his universe and must join with five spider-powered individuals from other dimensions to stop a threat for all realities.",
    releaseYear: 2018,
    genre: ["Animation", "Action", "Adventure"],
    runtime: 117,
    rating: 4.8,
    posterUrl: "https://image.tmdb.org/t/p/w500/ii2o424j2T52i5i4a17924l5d60.jpg"
  },
  {
    title: "Parasite",
    overview: "Greed and class discrimination threaten the newly formed symbiotic relationship between the wealthy Park family and the destitute Kim clan.",
    releaseYear: 2019,
    genre: ["Comedy", "Drama", "Thriller"],
    runtime: 132,
    rating: 4.6,
    posterUrl: "https://image.tmdb.org/t/p/w500/7IiT38S922vA4vS02p55a6dE930.jpg"
  },
  {
    title: "The Matrix",
    overview: "When a beautiful stranger leads computer hacker Neo to a forbidding underworld, he discovers the shocking truth--the life he knows is the elaborate deception of an evil cyber-intelligence.",
    releaseYear: 1999,
    genre: ["Action", "Sci-Fi"],
    runtime: 136,
    rating: 4.7,
    posterUrl: "https://image.tmdb.org/t/p/w500/f89U3w9rX922441f925232a90.jpg"
  },
  {
    title: "Pulp Fiction",
    overview: "The lives of two mob hitmen, a boxer, a gangster and his wife, and a pair of diner bandits intertwine in four tales of violence and redemption.",
    releaseYear: 1994,
    genre: ["Crime", "Drama"],
    runtime: 154,
    rating: 4.8,
    posterUrl: "https://image.tmdb.org/t/p/w500/d5A83669116e10l2004273295.jpg"
  },
  {
    title: "Whiplash",
    overview: "A promising young drummer enlists at a cut-throat music conservatory where his instructor will stop at nothing to realize his potential.",
    releaseYear: 2014,
    genre: ["Drama", "Music"],
    runtime: 106,
    rating: 4.6,
    posterUrl: "https://image.tmdb.org/t/p/w500/7fn62432924190l381907.jpg"
  }
];

const main = async () => {
  console.log('Cleaning existing movies...');
  await prisma.movie.deleteMany({
    where: { createdBy: userId }
  });

  console.log('Seeding database with actual TMDB movie poster paths...');
  for (const movie of moviesList) {
    await prisma.movie.create({
      data: {
        ...movie,
        createdBy: userId
      },
    });
    console.log(`[SUCCESS] Created: ${movie.title}`);
  }
  console.log('Finished seeding movies successfully.');
};

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
    await pool.end();
  });