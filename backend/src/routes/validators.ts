import {check} from "express-validator";
import moment from "moment";

export const checkDate = (field: string) => {
    return check(field, "invalid date type").custom((value) => moment(value).isValid());
};

export const checkDateIfPresent = (field: string) => {
    return check(field, "invalid date type").custom((value) => !value ||  moment(value).isValid());
};
