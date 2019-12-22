import { ServiceMessage, ServiceMessageError } from "./service_message";
import { PlainUser, UserModel, UserModelType } from "../models/user";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { config } from "../config/config";

interface RegisterUser {
    email: string;
    nickname: string;
    password: string;
}

interface LoginUser{
    email: string;
    password: string;
}

interface Token {
    token: string;
    refreshToken: string;
}

interface AuthService {
    registerUser: (user: RegisterUser) => Promise<ServiceMessage>;
    loginUser: (user: LoginUser) => Promise<Token>;
    refreshToken: (refreshToken: string) => Promise<Token>;
    getMe: (token: string) => Promise<PlainUser>;
    deleteUser: (token: string) => Promise<ServiceMessage>;
}

const createUserToken = async (userId: string) => {
    try {
        const u = await UserModel.findUser({id: userId}) as UserModelType;
        const user = new UserModel(u);
        
        const token = jwt.sign(user.id, config.jwtSecret, {
            expiresIn: "24h"
        });

        const refreshToken = jwt.sign(user.id, config.refreshJwtSecret, {
            expiresIn: "30 days"
        });

        const savedUser = await user.setTokenInfo({token, refreshToken})
        return savedUser.credentials.tokenInfo;
    } catch (err) {
        throw new ServiceMessageError("error while creating token", err);
    }
}

const refreshUserToken = async (refreshToken: string) => {
    let userId: string;
    try {
        userId = jwt.verify(refreshToken, config.refreshJwtSecret) as string;
    } catch (err) {
        throw new ServiceMessageError("invalid refresh token", err);
    }

    try {
        return createUserToken(userId);
    } catch(err) {
        throw new ServiceMessageError("could not create token", err);
    }
}
 // =============================================
 //                 SERVICE FUNCTIONS
 // =============================================

const registerUser = async (user: RegisterUser) => {
    try {
        await UserModel.createUser({...user})
        return {success: true, message: "user has been registered"}
    } catch (err) {
        throw new ServiceMessageError("failed to create user", err)
    }
}

const loginUser = async (userData: LoginUser) => {
    try {
        const user = await UserModel.findUser({email: userData.email}) as UserModelType;
        if (!user) {
            throw new ServiceMessageError("account has not been found");
        }
        if (!bcrypt.compareSync(userData.password, user.credentials.password)) {
            throw new ServiceMessageError("passwords don't match");
        }

        return createUserToken(user._id)
    } catch (err) {
        throw err;
    }
}

const refreshToken = async (token: string) => {
    return refreshUserToken(token);
}

const getMe = async (token: string) => {
    try {
        const userId = jwt.verify(token, config.jwtSecret) as string;
        const u = await UserModel.findUser({id: userId}) as UserModelType;
        if (!u) {
            throw new ServiceMessageError("account has not been found");
        }

        return new UserModel(u).plainUser;
    } catch (err) {
        if (err instanceof ServiceMessageError)
            throw err;
         
        throw new ServiceMessageError("invalid user token", err);
    }
}

const deleteUser = async (token: string) => {
    try {
        const userId = jwt.verify(token, config.jwtSecret) as string;
        await UserModel.deleteUser(userId);
        return {success: true, message: "account has been deleted"};
    } catch (err) {
        throw new ServiceMessageError("ecountered error while deleting user", err);
    }
}

const service: AuthService =  {
    loginUser,
    registerUser,
    refreshToken,
    getMe,
    deleteUser
};

export default service;