import express from 'express';
import { registerUser, loginUser, refreshToken, me, deleteUser } from '../controllers/user';
import {validateToken, hasRole} from "../middleware/auth";

const router = express.Router();


router.post("/register", registerUser);
router.post("/login", loginUser);
router.post("/token", refreshToken);

router.get("/me", [validateToken, me])

router.delete("/me", [validateToken, deleteUser]);
router.delete("/user/:userId", [validateToken, hasRole("admin"), deleteUser]);

export default router;