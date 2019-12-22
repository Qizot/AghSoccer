import jwt from "jsonwebtoken";
import { config } from "../config/config";


export enum TokenType {
    Simple,
    Refresh
}

export const extractUserIdFromToken = (token: string, type: TokenType) => {
    if (type === TokenType.Simple) {
        const {id} = jwt.verify(token, config.jwtSecret) as {id: string};
        return id;
    }
    const {id} = jwt.verify(token, config.refreshJwtSecret) as {id: string};
    return id;
}