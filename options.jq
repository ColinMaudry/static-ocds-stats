[.records[].compiledRelease] as $compiledReleases |
[$compiledReleases[] | .ocid as $ocid | .contracts | .[]? | .id |= ($ocid + .) ]  | unique_by(.id) as $contracts |
[$compiledReleases[].parties | .[]? | select(.roles | index("supplier"))] | unique_by(.identifier.id // .id) as $suppliers |
[$compiledReleases[].parties | .[]? | select(.roles | index("buyer"))] | unique_by(.identifier.id // .id) as $buyers |
[$compiledReleases[] | .ocid as $ocid | .tender.lots | .[]? | .id |= ($ocid + .) ]  | unique_by(.id) as $lots |

{
    "nb_contracts": $contracts | length,
    "nb_suppliers":  $suppliers | length,
    "nb_buyers": $buyers | length,
    "procedures": {
        "total":($compiledReleases | length),
        "active":([$compiledReleases[] | select(.tender.status == "active")] | length),
        "complete": ([$compiledReleases[] | select(.tender.status == "complete")] | length),
        "incomplete": ([$compiledReleases[] | select(
            .tender.status == "withdrawn" or
            .tender.status == "canceled" or
            .tender.status == "unsuccessful")] | length)
    },
    "lots":{
        "total": $lots | length,
        "active": ([$lots | .[] | select(.status = "active")] | length),
        "complete": ([$lots | .[] | select(.status = "complete")] | length),
        "incomplete":([$lots | .[] | select(
            .tender.status == "withdrawn" or
            .tender.status == "canceled" or
            .tender.status == "unsuccessful") ] | length)
    },
    "s": ($strings[0] | with_entries(.value |= .[$lang])),

    "startDate": $startDate,
    "endDate": $endDate
}
