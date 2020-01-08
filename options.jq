[.records[].compiledRelease] as $compiledReleases |
[$compiledReleases[] | .ocid as $ocid | .contracts | .[]? | .id |= ($ocid + .) ]  | unique_by(.id) as $contracts |
[$compiledReleases[].parties | .[]? | select(.roles | index("supplier"))] | unique_by(.identifier.id // .id) as $suppliers |
[$compiledReleases[].parties | .[]? | select(.roles | index("buyer"))] | unique_by(.identifier.id // .id) as $buyers |
[$compiledReleases[] | .ocid as $ocid | .tender.lots | .[]? | .id |= ($ocid + .) ]  | unique_by(.id) as $lots |

{
    "nb_contracts": $contracts | length,
    "nb_suppliers":  $suppliers | length,
    "nb_buyers": $buyers | length,
    "nb_procedures": ($compiledReleases | length),
    "nb_procedures_active": ([$compiledReleases[] | select(.tender.status == "active")] | length),
    "nb_procedures_incomplete": ([$compiledReleases[] | select(
        .tender.status == "withdrawn" or
        .tender.status == "canceled" or
        .tender.status == "unsuccessful")] | length),
    "nb_procedures_complete": ([$compiledReleases[] | select(.tender.status == "complete")] | length),
    "s": ($strings[0] | with_entries(.value |= .[$lang])),
    "lots":{
        "number": $lots | length,
        "numberActive": ([$lots | .[] | select(.status = "active")] | length),
        "numberComplete": ([$lots | .[] | select(.status = "complete")] | length),
        "numberIncomplete":([$lots | .[] | select(
            .tender.status == "withdrawn" or
            .tender.status == "canceled" or
            .tender.status == "unsuccessful") ] | length)
    },
    "startDate": $startDate,
    "endDate": $endDate
}
