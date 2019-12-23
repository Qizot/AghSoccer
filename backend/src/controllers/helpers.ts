import {Request, Response} from "express";
import HttpStatus from "http-status-codes";
import { ServiceMessageError } from "../services/service_message";

export const handleError = (res: Response, err: any) => {
    console.log("handleError: ", err);
    if (err instanceof ServiceMessageError) {
        const e = err as ServiceMessageError;
        return res.status(e.serviceMessage.statusCode || 500).json(e.serviceMessage);
    }

    return res.status(500).json({
        success: false,
        message: "internal server error",
        data: err,
    });
};

export const requestLackingUser = (res: Response) => {
    return res.status(HttpStatus.INTERNAL_SERVER_ERROR).json({
        success: false,
        message: "user has not been found in the request, middleware failed to stop request flow",
    });
};

export const extractRefreshToken = (req: Request) => {
    const data = req.body;
    let refreshToken = data.refreshToken as string;
    if (refreshToken && refreshToken.startsWith("Bearer ")) {
        refreshToken = refreshToken.slice(7);
    }
    return refreshToken;
};
