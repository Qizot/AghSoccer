import { Request, Response } from "express";
import HttpStatus from "http-status-codes";
import AuthService from "../services/auth";
import { handleError, extractRefreshToken, requestLackingUser } from "./helpers";

export const registerUser = (req: Request, res: Response) => {
    const data = req.body;
    const {email, nickname, password} = data;
    
    if (!email || !nickname || !password) {
        return res.status(HttpStatus.BAD_REQUEST).json({
            success: false,
            message: "missing fields"
        });
    }

    AuthService.registerUser({email, nickname, password})
    .then(msg => res.status(HttpStatus.CREATED).json(msg))
    .catch(err => handleError(res, err));
}

export const loginUser = (req: Request, res: Response) => {
    const data = req.body; 
    const {email, password} = data;
    
    if (!email || !password) {
        return res.status(HttpStatus.BAD_REQUEST).json({
            success: false,
            message: "missing fields"
        });
    }

    AuthService.loginUser({email, password})
    .then(token => {
        return res.status(HttpStatus.OK).json(token);
    })
    .catch(err => handleError(res, err));
}

export const refreshToken = (req: Request, res: Response) => {
    const refreshToken = extractRefreshToken(req);
    if (!refreshToken) {
        return res.status(HttpStatus.BAD_REQUEST).json({
            success: false,
            message: "refresh token has not been supplied"
        });
    }
    AuthService.refreshToken(refreshToken)
    .then(token => {
        return res.status(HttpStatus.OK).json(token);
    })
    .catch(err => handleError(res, err));
}

export const me = async (req: Request, res: Response) => {
    const {id} = req.user;
    if (!id) {
        return requestLackingUser(res);
    }

    AuthService.getMe(id)
    .then(user => res.status(HttpStatus.OK).json(user))
    .catch(err => handleError(res, err));
}

export const deleteUser = async (req: Request, res: Response) => {
    const {id, roles}: {id: string, roles: string[]} = req.user;
    let userId: string = req.params.userId;

    if (req.path.includes("me")) {
        userId = id;
    }

    if (!id) {
        return requestLackingUser(res);
    }

    if (roles.includes("admin") || id === userId) {
        AuthService.deleteUser(userId)
        .then(msg => res.status(HttpStatus.OK).json(msg))
        .catch(err => handleError(res, err));
    } else {
        return res.status(HttpStatus.FORBIDDEN).json({
            success: false,
            message: "insufficient permissions"
        });
    }
}