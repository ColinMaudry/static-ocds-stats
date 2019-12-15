.releases as $releases |
[$records[0].records[].compiledRelease] as $compiledReleases |
[ $compiledReleases[] | .ocid as $ocid | .contracts[] | .id |= ($ocid + .) ]  | unique_by(.id) as $contracts |
[$compiledReleases[].parties[] | select(.roles | index("supplier"))] | unique_by(.identifier.id // .id) as $suppliers |
[$compiledReleases[].parties[] | select(.roles | index("buyer"))] | unique_by(.identifier.id) as $buyers |

{
    "nb_contracts": $contracts | length,
    "nb_suppliers":  $suppliers | length,
    "nb_buyers": $buyers | length,
    "s": ($strings[0] | with_entries(.value |= .[$lang]))
}
