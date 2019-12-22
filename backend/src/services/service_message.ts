import { AnyTxtRecord } from "dns";

export interface ServiceMessage {
    success: boolean;
    message: string;
    data?: any;
}

export class ServiceMessageError extends Error {
    private data: any;

    constructor(message: string, data?: any) {
        super(message);
        this.message = message;
    }

    get serviceMessage(): ServiceMessage {
        return {success: false, message: this.message};
    }
}