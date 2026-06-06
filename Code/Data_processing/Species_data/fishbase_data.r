install.packages("rfishbase", dependencies = TRUE)
install.packages("dplyr")
library(rfishbase)
library(dplyr)

species_list <- read.csv("./external_data/spdata_std_for_fishbase_fetching.tsv", sep = '\t')$species_name
species_list <- species_list[species_list != ""]

sp_list      <- list()
eco_list     <- list()
country_list <- list()
occur_list   <- list()

for (spp in species_list) {
  cat("Processing:", spp, "\n")
  sp_list[[spp]]      <- tryCatch(species(spp),     error = function(e) NULL)
  eco_list[[spp]]     <- tryCatch(ecology(spp),     error = function(e) NULL)
  country_list[[spp]] <- tryCatch(country(spp),     error = function(e) NULL)
  occur_list[[spp]]   <- tryCatch(occurrence(spp),  error = function(e) NULL)
}

sp      <- bind_rows(sp_list)
eco     <- bind_rows(eco_list)
country_df <- bind_rows(country_list)
occur_df   <- bind_rows(occur_list)

cat("Done fetching. Rows — sp:", nrow(sp), "eco:", nrow(eco),
    "country:", nrow(country_df), "occurrence:", nrow(occur_df), "\n")

#  Family/Order from taxonomy table ─
tax <- load_taxa() %>%
  filter(Species %in% species_list) %>%
  select(Species, Family, Order, Class)

#  Country: flag India presence + all countries 
country_summary <- country_df %>%
  group_by(Species) %>%
  summarise(
    fb_in_india     = any(grepl("India", country, ignore.case = TRUE)),
    fb_india_status = paste(
      Status[grepl("India", country, ignore.case = TRUE)],
      collapse = "; "
    ),
    fb_countries_n  = n_distinct(country),
    .groups = "drop"
  )


#  Merge all ─
fb_data <- sp %>%
  select(Species, DemersPelag, Importance,
         UsedforAquaculture, Dangerous, GameFish,
         Length, CommonLength, Weight, LongevityWild,
         Fresh, Brack, Saltwater,
         DepthRangeShallow, DepthRangeDeep,
         Vulnerability, AnaCat) %>%
  left_join(eco %>% select(Species, FoodTroph, FeedingType), by = "Species") %>%
  left_join(tax,             by = "Species") %>%
  left_join(country_summary, by = "Species") %>%
  rename(
    species_name        = Species,
    fb_class            = Class,
    fb_order            = Order,
    fb_family           = Family,
    fb_habitat          = DemersPelag,
    fb_importance       = Importance,
    fb_aquaculture      = UsedforAquaculture,
    fb_dangerous        = Dangerous,
    fb_gamefish         = GameFish,
    fb_max_length_cm    = Length,
    fb_common_length_cm = CommonLength,
    fb_max_weight_g     = Weight,
    fb_max_age_years    = LongevityWild,
    fb_trophic_level    = FoodTroph,
    fb_feeding_type     = FeedingType,
    fb_freshwater       = Fresh,
    fb_brackish         = Brack,
    fb_saltwater        = Saltwater,
    fb_depth_min_m      = DepthRangeShallow,
    fb_depth_max_m      = DepthRangeDeep,
    fb_vulnerability    = Vulnerability,
    fb_anacat           = AnaCat
  )

write.csv(fb_data, "../fishbase_data.csv", row.names = FALSE)
cat("Saved to fishbase_data.csv —", nrow(fb_data), "rows\n")
