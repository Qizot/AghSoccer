import moment from "moment";
import {check} from "express-validator";

export const checkDate = (field: string) => {
    return check(field, "invalid date type").custom(value => moment(value).isValid())
}

export const checkDateIfPresent = (field: string) => {
    return check(field, "invalid date type").custom(value => !value ||  moment(value).isValid())
}

