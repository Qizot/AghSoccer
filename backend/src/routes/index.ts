import express from 'express';
import { registerUser, loginUser, refreshToken, me, deleteUser } from '../controllers/user';
import {validateToken, hasRole} from "../middleware/auth";
import { createMatch, editMatch, deleteMatch, confirmMatch, kickUserOut, enrollUser, derollUser, getMatch, getMatches } from '../controllers/matches';
import {check} from "express-validator";
import { checkDate, checkDateIfPresent } from './validators';
const router = express.Router();


router.post("/register", registerUser);
router.post("/login", loginUser);
router.post("/token", refreshToken);

router.get("/me", [validateToken, me])

router.delete("/me", [validateToken, deleteUser]);
router.delete("/users/:userId", [validateToken, hasRole("admin"), deleteUser]);


// match related;
router.get("/matches/:matchId", getMatch);
router.post("/matches/filter", [
    checkDate("timeFrom"),
    checkDate("timeTo"),
    getMatches
]);

router.post("/matches", [
    checkDate("startTime"),
    checkDate("endTime"),
    validateToken, 
    createMatch
]);
router.patch("/matches/:matchId", [
    checkDateIfPresent("startTime"),
    checkDateIfPresent("endTime"),
    validateToken, 
    editMatch
]);
router.delete("/matches/:matchId", [validateToken, deleteMatch]);

router.post("/matches/:matchId/confirm", [validateToken, confirmMatch]);
router.post("/matches/:matchId/kick", [validateToken, kickUserOut]);
router.post("/matches/:matchId/enroll", [validateToken, enrollUser]);
router.post("/matches/:matchId/deroll", [validateToken, derollUser]);


export default router;