// src/utils/date.js
export function formatTime(time, format = 'YYYY-MM-DD') {
    if (!time) return ''

    const date = new Date(time)
    const year = date.getFullYear()
    const month = date.getMonth() + 1
    const day = date.getDate()
    const hour = date.getHours()
    const minute = date.getMinutes()
    const second = date.getSeconds()

    const padZero = num => num < 10 ? `0${num}` : num

    return format
        .replace('YYYY', year)
        .replace('MM', padZero(month))
        .replace('DD', padZero(day))
        .replace('HH', padZero(hour))
        .replace('mm', padZero(minute))
        .replace('ss', padZero(second))
}
