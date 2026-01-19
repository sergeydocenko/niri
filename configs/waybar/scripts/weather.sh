#!/usr/bin/env bash

# Thanks to
# https://github.com/maxmx03/dotfiles/blob/main/.config/waybar/scripts/weather

declare wc=(
    "☀️"
    "⛅"
    "☁️"
    "🌧️"
    "⛈️"
    "❄️"
)

declare -A WEATHER_CODES=(
    ["0"]="${wc[0]}"
    ["1"]="${wc[1]}"
    ["2"]="${wc[1]}"
    ["3"]="${wc[1]}"
    ["45"]="${wc[2]}"
    ["48"]="${wc[2]}"
    ["51"]="${wc[3]}"
    ["53"]="${wc[3]}"
    ["55"]="${wc[3]}"
    ["61"]="${wc[3]}"
    ["63"]="${wc[3]}"
    ["65"]="${wc[3]}"
    ["66"]="${wc[3]}"
    ["67"]="${wc[3]}"
    ["71"]="${wc[5]}"
    ["73"]="${wc[5]}"
    ["75"]="${wc[5]}"
    ["77"]="${wc[5]}"
    ["80"]="${wc[3]}"
    ["81"]="${wc[3]}"
    ["82"]="${wc[3]}"
    ["85"]="${wc[5]}"
    ["86"]="${wc[5]}"
    ["95"]="${wc[4]}"
    ["96"]="${wc[4]}"
    ["99"]="${wc[4]}"
)

DATE=$(LC_ALL=ru_RU.UTF-8 date '+%F (%a) %H:%M')

LOCATION_NAME="Lubotin $DATE"
LAT="49.948333"
LON="35.929444"

DATA=$(
    curl -s "https://api.open-meteo.com/v1/forecast" \
        --data-urlencode "latitude=$LAT" \
        --data-urlencode "longitude=$LON" \
        --data-urlencode "current=temperature_2m,wind_speed_10m,wind_direction_10m,relative_humidity_2m,weather_code,precipitation,surface_pressure" \
        --data-urlencode "daily=temperature_2m_max,temperature_2m_min,sunrise,sunset,precipitation_sum,precipitation_probability_max" \
        --data-urlencode "timezone=auto" \
        --data-urlencode "wind_speed_unit=ms" \
        --data-urlencode "forecast_days=1"
)
#echo $weather
TEMP_UNITS=($(jq -r ".current_units.temperature_2m" <<<"$DATA"))
WIND_UNITS=($(jq -r ".current_units.wind_speed_10m" <<<"$DATA"))
PRECIPITATION_UNITS=($(jq -r ".current_units.precipitation" <<<"$DATA"))
WIND_DIRECTION_UNITS=($(jq -r ".current_units.wind_direction_10m" <<<"$DATA"))
PRESSURE_UNITS="mmHg"

CURRENT_WEATHER_CODE=($(jq -r ".current.weather_code" <<<"$DATA"))
CURRENT_WEATHER_ICON=${WEATHER_CODES[$CURRENT_WEATHER_CODE]}

CURRENT_TEMP=($(jq -r ".current.temperature_2m" <<<"$DATA" | xargs printf "%0.f\n"))
[[ "$CURRENT_TEMP" == "-0" ]] && CURRENT_TEMP="0"

CURRENT_WIND=($(jq -r ".current.wind_speed_10m" <<<"$DATA" | xargs printf "%0.f\n"))

CURRENT_WIND_DIRECTION=($(jq -r ".current.wind_direction_10m" <<<"$DATA"))

CURRENT_HUMID=($(jq -r ".current.relative_humidity_2m" <<<"$DATA"))
CURRENT_PRESSURE=($(jq -r ".current.surface_pressure" <<<"$DATA" | awk '{printf "%.f\n", $1 * 0.750062}'))
CURRENT_PRECIPITATION=($(jq -r ".current.precipitation" <<<"$DATA" | xargs printf "%0.f\n"))

TODAY_TEMP_MIN=($(jq -r ".daily.temperature_2m_min[0]" <<<"$DATA" | xargs printf "%.0f\n"))
[[ "$TODAY_TEMP_MIN" == "-0" ]] && TODAY_TEMP_MIN="0"

TODAY_TEMP_MAX=($(jq -r ".daily.temperature_2m_max[0]" <<<"$DATA" | xargs printf "%.0f\n"))
[[ "$TODAY_TEMP_MAX" == "-0" ]] && TODAY_TEMP_MAX="0"

TODAY_SUNRISE=($(jq -r ".daily.sunrise[0]" <<<"$DATA" | cut -d'T' -f2))
TODAY_SUNSET=($(jq -r ".daily.sunset[0]" <<<"$DATA" | cut -d'T' -f2))
TODAY_PRECIPITATION=($(jq -r ".daily.precipitation_sum[0]" <<<"$DATA" | xargs printf "%0.f\n"))
TODAY_PRECIPITATION_PROBALITY_MAX=($(jq -r ".daily.precipitation_probability_max[0]" <<<"$DATA"))

DIR_LABELS=("↓" "↙" "←" "↖" "↑" "↗" "→" "↘")
#DIR_LABELS=("С ↓" "СВ ↙" "В ←" "ЮВ ↖" "Ю ↑" "ЮЗ ↗" "З →" "СЗ ↘")
#DIR_LABELS=("N ↓" "NE ↙" "E ←" "SE ↖" "S ↑" "SW ↗" "W →" "NW ↘")
INDEX=$(((CURRENT_WIND_DIRECTION + 22) % 360 / 45))
CURRENT_WIND_DIRECTION_HUMANIZED="${DIR_LABELS[$INDEX]}"

case "$1" in
"bar")
    echo "$CURRENT_WEATHER_ICON $CURRENT_TEMP$TEMP_UNITS $CURRENT_PRECIPITATION$PRECIPITATION_UNITS $CURRENT_WIND_DIRECTION_HUMANIZED $CURRENT_WIND$WIND_UNITS"
    ;;
"notify")
    DETAIL="\n"
    DETAIL+="<b>Текущая погода</b>\n"
    DETAIL+="    Температура : <b>$CURRENT_TEMP$TEMP_UNITS</b>\n"
    DETAIL+="    Ветер       : <b>$CURRENT_WIND$WIND_UNITS $CURRENT_WIND_DIRECTION_HUMANIZED</b>\n"
    DETAIL+="    Влажность   : <b>$CURRENT_HUMID%</b>\n"
    DETAIL+="    Осадки      : <b>$CURRENT_PRECIPITATION$PRECIPITATION_UNITS</b>\n"
    DETAIL+="    Давление    : <b>$CURRENT_PRESSURE $PRESSURE_UNITS</b>\n"
    DETAIL+="<b>Суточная погода</b>\n"
    DETAIL+="    Температура : <b>$TODAY_TEMP_MIN$TEMP_UNITS</b> .. <b>$TODAY_TEMP_MAX$TEMP_UNITS</b>\n"
    DETAIL+="    Осадки      : <b>$TODAY_PRECIPITATION$PRECIPITATION_UNITS ($TODAY_PRECIPITATION_PROBALITY_MAX%)</b>\n"
    DETAIL+="    Восход/Закат: <b>$TODAY_SUNRISE</b> .. <b>$TODAY_SUNSET</b>"
    notify-send --expire-time=30000 "$LOCATION_NAME $CURRENT_WEATHER_ICON" "$DETAIL"
    ;;
esac
