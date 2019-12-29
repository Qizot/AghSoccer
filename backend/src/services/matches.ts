import { CreateMatchType, MatchModel, MatchModelType, MatchRepository, PlainMatch } from "../models/match";
import { ServiceMessage, ServiceMessageError } from "./service_message";
import { UserModel, UserModelType } from "../models/user";

interface EditMatch {
    name: string;
    description: string;
    password: string;
    startTime: Date;
    endTime: Date;
    changePassword: boolean;
}

interface MatchFilter {
    showPrivate: boolean;
    timeFrom: Date;
    timeTo: Date;
}

interface MatchOwner {
    id: string;
}

interface MatchService {
    createMatch: (owner: MatchOwner, match: CreateMatchType) => Promise<ServiceMessage>;
    editMatch: (owner: MatchOwner, matchId: string, editMatch: Partial<EditMatch>) => Promise<ServiceMessage>;
    deleteMatch: (owner: MatchOwner, matchId: string) => Promise<ServiceMessage>;
    confirmMatch: (dsnetToken: string) => Promise<ServiceMessage>;
    kickUserOut: (owner: MatchOwner, matchId: string, userNickname: string) => Promise<ServiceMessage>;

    // enroll and deroll return updated match document so frontend doesn't have to fetch it again
    enrollUser: (userId: string, matchId: string, password?: string) => Promise<ServiceMessage>;
    derollUser: (userId: string, matchId: string) => Promise<ServiceMessage>;
    getMatch: (matchId: string) => Promise<PlainMatch>;
    getMatches: (filter: MatchFilter) => Promise<PlainMatch[]>;
}

const getOwnersMatch = async (owner: MatchOwner, matchId: string) => {
    const match = await MatchModel.findMatch(matchId) as MatchModelType;
    if (!match) {
        throw new ServiceMessageError(404, "match has not been found");
    }

    if (match.ownerId.toString() !== owner.id.toString()) {
        throw new ServiceMessageError(403, "given user is not match's owner");
    }
    return match;
};

const getUserNickname = async (userId: string) => {
    const user = await UserModel.findUser({id: userId}) as UserModelType;
    if (!user) {
        throw new ServiceMessageError(404, "user has not been found");
    }
    return user.nickname;
}

const createMatch = async (owner: MatchOwner, match: CreateMatchType) => {
    try {
        const createdMatch = await MatchModel.createMatch({...match, ownerId: owner.id}) as MatchModelType;
        return {success: true, message: "match has been created", data: new MatchModel(createdMatch).plainMatch};
    } catch (err) {
        if (err instanceof ServiceMessageError) { throw err; }
        if (err instanceof Error) { throw new ServiceMessageError(400, err.message); }
        throw new ServiceMessageError(500, "could not create match, not enough information to determine why", err);
    }
};

const editMatch = async (owner: MatchOwner, matchId: string,  editMatch: Partial<EditMatch>) => {
    try {
        const match = await getOwnersMatch(owner, matchId);

        if (editMatch.name) { match.name = editMatch.name; }
        if (editMatch.description) { match.description = editMatch.description; }
        if (editMatch.startTime) { match.startTime = editMatch.startTime; }
        if (editMatch.endTime) { match.endTime = editMatch.endTime; }
        if (editMatch.changePassword) {
            match.password = editMatch.password;
        }

        await match.save();
        return {success: true, message: "match has been updated"};
    } catch (err) {
        if (err instanceof ServiceMessageError) { throw err; }
        if (err instanceof Error) { throw new ServiceMessageError(400, err.message); }
        throw new ServiceMessageError(500, "unknown error while edditing match", err);
    }
};

const deleteMatch = async (owner: MatchOwner, matchId: string) => {
    try {
        const match = await getOwnersMatch(owner, matchId);

        await match.remove();
        return {success: true, message: "match has been deleted"};
    } catch (err) {
        if (err instanceof ServiceMessageError) { throw err; }

        throw new ServiceMessageError(500, "unknown error while edditing match", err);
    }
};

const confirmMatch = async (dsnetToken: string) => {
    throw new ServiceMessageError(501, "confirming matches has not been implemented yet");
    return {success: false, message: "it won't even get here so why even bother"};
};

const kickUserOut = async (owner: MatchOwner, matchId: string,  userNickname: string) => {
    try {
        const match = await getOwnersMatch(owner, matchId);

        if (!match.players.includes(userNickname)) {
            throw new ServiceMessageError(400, "given user has not been enrolled");
        }

        await new MatchModel(match).derollUser(userNickname);
	    const updated = await getOwnersMatch(owner, matchId); 
        return {success: true, message: "user has been kicked out", data: new MatchModel(updated).plainMatch};
    } catch (err) {
        if (err instanceof ServiceMessageError) { throw err; }

        throw new ServiceMessageError(500, "unknown error while kicking player out", err);
    }
};

const enrollUser = async (userId: string, matchId: string, password?: string) => {
    try {
        const match = await MatchModel.findMatch(matchId) as MatchModelType;
        const user = await getUserNickname(userId);
        if (!match) {
            throw new ServiceMessageError(404, "match has not been found");
        }

        if (match.password && match.password !== password) {
            throw new ServiceMessageError(403, "passwords don't match");
        }

        if (match.players.includes(user)) {
            throw new ServiceMessageError(400, "user has been already enrolled");
        }

        await new MatchModel(match).enrollUser(user) as MatchModelType;
        const updated = await MatchModel.findMatch(matchId) as MatchModelType;
        return {success: true, message: "user has been enrolled", data: new MatchModel(updated).plainMatch};
    } catch (err) {
        if (err instanceof ServiceMessageError) { throw err; }
        console.log("enrolling: ", err);
        throw new ServiceMessageError(500, "unknown error while enrolling player", err);
    }
};

const derollUser = async (userId: string, matchId: string) => {
    try {
        const match = await MatchModel.findMatch(matchId) as MatchModelType;
        const user = await getUserNickname(userId);
        if (!match) {
            throw new ServiceMessageError(404, "match has not been found");
        }

        if (!match.players.includes(user)) {
            throw new ServiceMessageError(400, "user has not been enrolled");
        }

        await new MatchModel(match).derollUser(user) as MatchModelType;
        const updated = await MatchModel.findMatch(matchId) as MatchModelType;
        return {success: true, message: "user has been derolled", data: new MatchModel(updated).plainMatch};
    } catch (err) {
        if (err instanceof ServiceMessageError) { throw err; }

        throw new ServiceMessageError(500, "unknown error while derolling player", err);
    }
};

const getMatch = async (matchId: string) => {
    try {
        const match = await MatchModel.findMatch(matchId) as MatchModelType;
        if (!match) {
            throw new ServiceMessageError(404, "match has not been found");
        }
        return new MatchModel(match).plainMatch;
    } catch (err) {
        if (err instanceof ServiceMessageError) { throw err; }

        throw new ServiceMessageError(500, "unknown error while getting match", err);
    }
};

const getMatches = async (filter: MatchFilter) => {
    try {
        const repo = new MatchRepository();

        const publicOnly = filter.showPrivate ? undefined : {
            password: {$exists: false},
        };

        const matches = await repo.find({
            startTime: {
                $gte: filter.timeFrom,
            } ,
            endTime: {
                $lte: filter.timeTo,
            },
            publicOnly,
        });
        console.log(matches);
        console.log(filter.timeFrom.toISOString(), filter.timeTo.toISOString());

        return matches.map((m) => new MatchModel(m as MatchModelType).plainMatch);
    } catch (err) {
        if (err instanceof ServiceMessageError) { throw err; }

        throw new ServiceMessageError(500, "unknown error while getting matches", err);
    }
};

const service: MatchService = {
    createMatch,
    editMatch,
    deleteMatch,
    confirmMatch,
    kickUserOut,
    enrollUser,
    derollUser,
    getMatch,
    getMatches,
};

export default service;
