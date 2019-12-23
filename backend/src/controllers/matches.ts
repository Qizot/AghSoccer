import { Request, Response } from "express";
import HttpStatus from "http-status-codes";
import MatchService from "../services/matches";
import { handleError, requestLackingUser } from "./helpers";
import { validationResult } from "express-validator";

export const createMatch = (req: Request, res: Response) => {
    const data = req.body;
    const {name, description, password, startTime, endTime} = data;
    const {id} = req.user;

    if (!id) {
        return requestLackingUser(res);
    }

    if (!name || !startTime || !endTime) {
        return res.status(HttpStatus.BAD_REQUEST).json({
            success: false,
            message: "missing fields, required: (name, startTime, endTime)"
        })
    }

    const errors = validationResult(req);
    if(!errors.isEmpty()) {
        return res.status(HttpStatus.BAD_REQUEST).json({
            success: false,
            message: errors.array()
        })
    }

    MatchService.createMatch({id}, {
        name, 
        description, 
        password, 
        startTime: new Date(startTime), 
        endTime: new Date(endTime), 
        ownerId: id
    }).then(msg => res.status(HttpStatus.CREATED).json(msg))
    .catch(err => handleError(res, err));
}

export const editMatch = (req: Request, res: Response) => {
    const data = req.body;
    const {name, description, password, startTime, endTime} = data;
    const matchId = req.params.matchId;
    const {id} = req.user

    if (!id) {
        return requestLackingUser(res);
    }

    const errors = validationResult(req);
    if(!errors.isEmpty()) {
        res.status(HttpStatus.BAD_REQUEST).json({
            success: false,
            message: errors.array()
        })
    }

    MatchService.editMatch({id}, matchId, {
        name,
        description,
        password,
        startTime: startTime && new Date(startTime),
        endTime: endTime && new Date(endTime)
    }).then(msg => res.status(HttpStatus.OK).json(msg))
    .catch(err => handleError(res, err));
}

export const deleteMatch = (req: Request, res: Response) => {
    const matchId = req.params.matchId;
    const {id} = req.user;

    if (!id) {
        return requestLackingUser(res);
    }

    MatchService.deleteMatch({id}, matchId)
    .then(msg => res.status(HttpStatus.OK).json(msg))
    .catch(err => handleError(res, err));
}

export const confirmMatch = (req: Request, res: Response) => {
    const matchId = req.params.matchId;
    const data = req.body;
    const {dsnetToken} = data;

    MatchService.confirmMatch(dsnetToken)
    .then(msg => res.status(HttpStatus.OK).json(msg))
    .catch(err => handleError(res, err));
}

export const kickUserOut = (req: Request, res: Response) => {
    const matchId = req.params.matchId;
    const data = req.body;
    const {userId} = data;
    const {id} = req.user;

    if (!id) {
        return requestLackingUser(res);
    }

    MatchService.kickUserOut({id}, matchId, userId)
    .then(msg => res.status(HttpStatus.OK).json(msg))
    .catch(err => handleError(res, err));
}

export const enrollUser = (req: Request, res: Response) => {
    const matchId = req.params.matchId;
    const {id} = req.user;
    const data = req.body;
    const {password} = data;

    if (!id) {
        return requestLackingUser(res);
    }

    MatchService.enrollUser(id, matchId, password)
    .then(msg => res.status(HttpStatus.OK).json(msg))
    .catch(err => handleError(res, err));
}

export const derollUser = (req: Request, res: Response) => {
    const matchId = req.params.matchId;
    const {id} = req.user;

    if (!id) {
        return requestLackingUser(res);
    }

    MatchService.derollUser(id, matchId)
    .then(msg => res.status(HttpStatus.OK).json(msg))
    .catch(err => handleError(res, err));
}

export const getMatch = (req: Request, res: Response) => {
    const matchId = req.params.matchId;

    MatchService.getMatch(matchId)
    .then(match => res.status(HttpStatus.OK).json(match))
    .catch(err => handleError(res, err));
}

export const getMatches = (req: Request, res: Response) => {
    const data = req.body;
    const {showPrivate, timeFrom, timeTo} = data;
    if (showPrivate === undefined || !timeFrom || !timeTo) {
        return res.status(HttpStatus.BAD_REQUEST).json({
            success: false,
            message: "missing fields, required: (showPrivate, timeFrom, timeTo)"
        });
    }

    const errors = validationResult(req);
    if(!errors.isEmpty()) {
        res.status(HttpStatus.BAD_REQUEST).json({
            success: false,
            message: errors.array()
        })
    }

    MatchService.getMatches({
        showPrivate,
        timeFrom: new Date(timeFrom),
        timeTo: new Date(timeTo)
    }).then(matches => res.status(HttpStatus.OK).json(matches))
    .catch(err => handleError(res, err));
}



