
import jwt from "jsonwebtoken";
import { config } from "../config/config";
import { UserModel } from "../models/user";


const validateToken = (req, res, next) => {
    let token = req.headers['x-access-token'] || req.headers['authorization'];
    if (token && token.startsWith('Bearer ')) {
      token = token.slice(7, token.length);
    } else {
        return res.status(400).json({
            success: false,
            message: "invalid token format"
        });
    }
  
    let userId: string;
    try {
        userId = jwt.verify(token, config.jwtSecret) as string;
    } catch (err) {
        return res.status(401).json({
            success: false,
            message: "token is invalid"
        });
    }
    
    let user;
    try {
        user = UserModel.findOne({id: userId}, {"_id": 1, "roles": 1});
        if (!user) {
            return res.status(404).json({
                success: false,
                message: "user has not been found"
            });
        }
    } catch (err) {
        return res.status(500).json({
            success: false,
            message: "internal error while fetching user"
        });
    }
  
      req.user = {id: user._id, roles: user.roles};
      next();
};

const hasRole = (role: string) => {
    return function(req, res, next) {
        const user = req.user;
        if (!user) {
            return res.status(500).json({
                success: false,
                message: "request lacking user info"
            });
        }
        if (user && user.roles && user.roles.includes(role)) {
            next();
            return;
        }
        return res.status(401).json({
            success: false,
            message: "insufficient permissions"
        });
    }
}