import jwt from 'jsonwebtoken';
import { prisma } from '../config/db.js';

export const authMiddleware = async (req, res, next) => {
    let token;
    if (req.headers.authorization && req.headers.authorization.startsWith("Bearer")) {
        token = req.headers.authorization.split(" ")[1];
    }
    else if (req.cookies?.jwt) {
        token = req.cookies.jwt;
    }

    if(!token) {
        return res.status(401).json({
            message: 'Not authorize, no token provided'
        });
    }

    try {
        const decode = jwt.verify(token, process.env.JWT_SECRET)
        const user = await prisma.user.findUnique({
            where: {id: decode.id},
        });

        if (!user) {
            return res.status(401).json({
                error: "User doesn't exist"
            })
        }
        req.user = user;
        next();
    } catch (e) {
        return res.status(401).json({
            error: `Not authorize, token failed`
        })
    }
}