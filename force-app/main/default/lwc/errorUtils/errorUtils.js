export function reduceErrors(error) {
    if (Array.isArray(error?.body)) {
        return error.body.map(e => e.message);
    } else if (typeof error?.body?.message === 'string') {
        return [error.body.message];
    } else if (typeof error?.message === 'string') {
        return [error.message];
    } else {
        return ['Unknown error'];
    }
}
