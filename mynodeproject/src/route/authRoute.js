import express from 'express';
import { register, login, logout } from '../controller/authController.js';
import { loginSchema, registerSchema } from '../validators/authValidator.js';
import { validateRequest } from '../middleWare/validateRequest.js';
const router = express.Router();

router.post('/register',validateRequest(registerSchema), register)
router.post('/login',validateRequest(loginSchema), login)
router.post('/logout', logout)

export default router;