.releases as $releases |
[ $releases[].contracts ] as $contracts |
[$releases[].parties[] | select(.roles | index("supplier"))] | unique_by(.identifier.id) as $suppliers |
[$releases[].parties[] | select(.roles | index("buyer"))] | unique_by(.identifier.id) as $buyers |

{
    "nb_contracts": $contracts | length,
    "nb_suppliers":  $suppliers | length,
    "nb_buyers": $buyers | length,
    "s": ($strings[0] | with_entries(.value |= .[$lang]))
}


#(.value |= .value.fr)
