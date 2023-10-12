create_subsets <- function(disease_data, filter_reference){
  tmp1 <- disease_data %>%
    filter(ID_MN_RESI %in% filter_reference$mun) %>%
    rename(code_muni = ID_MN_RESI, date = DT_SIN_PRI, cases = freq)

  tmp2 <- tmp1 %>%
    arrange(code_muni) %>%
    pivot_wider(names_from = code_muni, values_from = cases) %>%
    select(-date) %>%
    t() %>%
    tslist()

  k_seq <- 3:10

  tmp3 <- tsclust(
    series = tmp2,
    type = "partitional",
    k = k_seq,
    distance = "sbd",
    seed = 13
  )

  names(tmp3) <- paste0("k_", k_seq)
  res_cvi <- sapply(tmp3, cvi, type = "internal") %>%
    t() %>%
    as_tibble(rownames = "k") %>%
    arrange(-Sil)

  sel_clust <- tmp3[[res_cvi[[1,1]]]]

  cluster_ids <- tibble(
    code_muni = names(tmp2),
    subset = as.character(sel_clust@cluster)
  )

  return(cluster_ids)
}
