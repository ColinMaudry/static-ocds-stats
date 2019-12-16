($startDateIso | fromdateiso8601) as $startDate |
($endDateIso | fromdateiso8601) as $endDate |

  . | .releases |=
    [.[] |
        select(
            (.date? |
            sub("[\\+\\-][0-9][0-9]\\:[0-9][0-9]"; "Z")
            | fromdateiso8601) >= $startDate
            and  (.date? |
            sub("[\\+\\-][0-9][0-9]\\:[0-9][0-9]"; "Z")
            | fromdateiso8601) <= $endDate)]

#. | .releases
