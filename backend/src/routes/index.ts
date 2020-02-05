import express, {Request, Response} from "express";
import { confirmMatch, createMatch, deleteMatch, derollUser, editMatch, enrollUser, getMatch, getMatches, kickUserOut, listMatchesByIds } from "../controllers/matches";
import { deleteUser, loginUser, me, refreshToken, registerUser } from "../controllers/user";
import {hasRole, validateToken} from "../middleware/auth";
import { checkDate, checkDateIfPresent } from "./validators";
import { check } from "express-validator";
const router = express.Router();

router.get("/ping", (req: Request, res: Response) => {
    res.status(200).send("pong");
});

router.post("/register", [
    check("email").isEmail(),
    registerUser
]);
router.post("/login", loginUser);
router.post("/token", refreshToken);

router.get("/me", [validateToken, me]);

router.delete("/me", [validateToken, deleteUser]);
router.delete("/users/:userId", [validateToken, hasRole("admin"), deleteUser]);

// match related;
router.get("/matches/:matchId", getMatch);
router.post("/matches/list", listMatchesByIds);
router.post("/matches/filter", [
    checkDate("timeFrom"),
    checkDate("timeTo"),
    getMatches,
]);

router.post("/matches", [
    checkDate("startTime"),
    checkDate("endTime"),
    validateToken,
    createMatch,
]);
router.patch("/matches/:matchId", [
    checkDateIfPresent("startTime"),
    checkDateIfPresent("endTime"),
    validateToken,
    editMatch,
]);
router.delete("/matches/:matchId", [validateToken, deleteMatch]);

router.post("/matches/:matchId/confirm", [validateToken, confirmMatch]);
router.post("/matches/:matchId/kick", [validateToken, kickUserOut]);
router.post("/matches/:matchId/enroll", [validateToken, enrollUser]);
router.post("/matches/:matchId/deroll", [validateToken, derollUser]);

export default router;
