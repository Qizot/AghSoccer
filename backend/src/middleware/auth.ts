
import jwt from "jsonwebtoken";
import { config } from "../config/config";
import { UserModel } from "../models/user";
import { Request, Response, NextFunction } from "express";

export enum TokenResult {
    Success = "user has been authenticated",
    InvalidFormat = "invalid token format",
    InvalidToken = "token is invalid",
    UserNotFound = "user has not been found",
    ExpiredToken = "token is too old",
    DatabaseError = "internal error while fetching user"
}

interface UserInfo {
    id: string;
    nickname: string;
    roles: string[];
}
type CheckTokenResult = ({token, omitFormatCheck}: {token: string; omitFormatCheck?: boolean}) => Promise<{status: TokenResult; user?: UserInfo}>;

export const checkToken: CheckTokenResult = async ({token, omitFormatCheck = false}) => {
    let tkn = token;
    if (!omitFormatCheck) {
        if (token && token.startsWith("Bearer ")) {
            token = token.slice(7, token.length);
        } else {
            return {status: TokenResult.InvalidFormat};
        }
    }

    let userId: string;
    try {
        const {id} = jwt.verify(token, config.jwtSecret) as {id: string};
        userId = id;
    } catch (err) {
        return {status: TokenResult.InvalidToken};
    }

    let user;
    try {
        user = await UserModel.findOne({_id: userId}, {"_id": 1, "roles": 1, "nickname": 1, "credentials.tokenInfo.token": 1});
        if (!user) {
            return {status: TokenResult.UserNotFound};
        }
        if (user.credentials.tokenInfo.token !== token) {
            return {status: TokenResult.ExpiredToken}
        }
    } catch (err) {
        return {status: TokenResult.DatabaseError};
    }

    return {
        status: TokenResult.Success, 
        user: {
            id: user._id,
            nickname: user.nickname,
            roles: user.roles
        }
    };
}

export const validateToken = async (req: Request, res: Response, next: NextFunction) => {
    let token = req.headers.authorization;

    const { status, user } = await checkToken({token});

    // error message when status is different to Success
    const errorMessage = {status: false, message: status};

    switch (status) {
        case TokenResult.InvalidFormat: {
            return res.status(400).json(errorMessage);
        }
        case TokenResult.InvalidToken: {
            return res.status(401).json(errorMessage);
        }
        case TokenResult.UserNotFound: {
            return res.status(404).json(errorMessage);
        }
        case TokenResult.ExpiredToken: {
            return res.status(401).json(errorMessage);
        }
        case TokenResult.DatabaseError: {
            return res.status(500).json(errorMessage);
        }
        case TokenResult.Success: {
            req.user = {...user};
            next();
        }
    }
};

export const hasRole = (role: string) => {
    return function(req: Request, res: Response, next: NextFunction) {
        const user = req.user;
        if (!user) {
            return res.status(500).json({
                success: false,
                message: "request lacking user info",
            });
        }
        if (user && user.roles && user.roles.includes(role)) {
            next();
            return;
        }
        return res.status(401).json({
            success: false,
            message: "insufficient permissions",
        });
    };
};
