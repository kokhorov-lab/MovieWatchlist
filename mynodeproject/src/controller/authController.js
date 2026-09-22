import bcrypt from 'bcryptjs';
import { prisma } from '../config/db.js';
import { generateToken } from '../utils/generateToken.js';


const register = async (req, res) => {
   const {name, email, password} = req.body;

   const userExists = await prisma.user.findUnique({
    where: { email: email }
   });

   if(userExists) {
    return res.status(400).json({error: 'User already exits'});
   }

   // Hash password
   const salt = await bcrypt.genSalt(10);
   const hashedPassword = await bcrypt.hash(password, salt);

   const user = await prisma.user.create({
    data: {
        email,
        name,
        password: hashedPassword
    }
   });

   res.status(201).json({
    message: 'User created successfully',
    data: {
        user:{
            id: user.id,
            email: user.email,
            name: user.name,
        }
    }
   })
};

const login = async (req, res) => {
    const {email, password} = req.body;
    const user = await prisma.user.findUnique({
        where: { email: email}
    })

    if(!user){
        return res.status(400).json({error: 'Invalid email or password'});
    }

    

    //verify password

    const isPasswordValid = await bcrypt.compare(password, user.password);

    if(!isPasswordValid) {
        return res.status(401).json({error: 'Invalid email or password'});
    }

    //generate token
    const token = generateToken(user.id, res);

    res.status(201).json({
        message: 'Login successful',
        data: {
            user: {
                id: user.id,
                name: user.name,
                email: email,
            }, 
            token,
        }
    })
}

const logout = (req, res) => {
    res.cookie('jwt', '',{
        httpOnly: true,
        expires: new Date(0)
    })
    res.status(200).json({
        status: 'success',
        message: 'Logout successful'
    })
}

export { register, login, logout };