
export interface ServiceMessage {
    statusCode?: number;
    success: boolean;
    message: string;
    data?: any;
}

export class ServiceMessageError extends Error {
    
    private data: any;
    private statusCode: number;

    constructor(statusCode: number, message: string, data?: any) {
        super(message);
        this.statusCode = statusCode;
        this.message = message;

    }

    get serviceMessage(): ServiceMessage {
        return {success: false, message: this.message, statusCode: this.statusCode, data: this.data};
    }
}