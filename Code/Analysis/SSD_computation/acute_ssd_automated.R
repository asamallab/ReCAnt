## Title: Acute SSD computations
## Date: 23-12-2024
## Last modified by: Shreyes


################################################################################
# Import the required libraries
packages <- c("doFuture", "foreach", "ssdtools", "ggplot2", "future", "here", "svglite")
options(repos = c(CRAN = "https://cloud.r-project.org"))
for (pkg in packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg, character.only = TRUE)
    library(pkg, character.only = TRUE)
  } else {
    library(pkg, character.only = TRUE)
  }
}
print("Imported required libraries successfully")

# start the logging file
sink(file="acute_code_full_log.txt", split=TRUE)

# set home directory
home = "./Aquaculture/ECOTOX/Codes"
setwd(dirname(home))

# print home directory
print("Home directory set to:")
print(getwd())


################################################################################
# Cores in the CPU
# Logical cores; for physical set logical=FALSE
n_cores <- availableCores(logical = TRUE)
print(sprintf("No of physical cores in the CPU: %s", n_cores))

# Allot cores
# Register cluster
# cl <- makeCluster(n_cores - 4)
crs = max(1, n_cores - 4)
print(sprintf("Number of cores to use: %s", crs))
plan(multisession, workers = crs)
registerDoFuture()

################################################################################
# read the chemicals list
ssd_chemicals_path = file.path(home, "ssd_input", "ssd_chemicals.tsv")
ssd_chemicals = read.csv(ssd_chemicals_path, sep='\t')
colnames(ssd_chemicals) <- make.names(colnames(ssd_chemicals))

# set path for saving results
save_path = file.path(home, "ssd_output", "acute")
print("Results will be stored in the following location:")
save_path


################################################################################
# FUNCTIONS (with tryCatch() for error-handling)
# This function plots and exports fits for all models in a single figure
# It returns the name of the best fit model, and the model parameters (see 'dist')
# for all models
plot_allmodels <- function(df, cas, cname, lbls) {
  
  tryCatch(
    expr = {
      dist <- ssd_fit_dists(df, left = 'Conc', dists = c('lnorm', 'llogis','lgumbel', 'weibull', 'burrIII3'), silent = FALSE, reweight = FALSE, min_pmix = 0, nrow = 5L, computable = TRUE, rescale = FALSE, at_boundary_ok = TRUE)
      
      x_label = sprintf('Concentration of %s (equivalent ppm)', cname)
      all_models_plot = ssd_plot_cdf(dist, delta = Inf, xlab=x_label, ylab='Percent of Species Affected', label = 'Latin.Name', shift_x=1.5, label_size=lbls)
      
      gof = ssd_gof(dist)
      path1 = file.path(save_path, sprintf("%s", cas), sprintf("%s_gof.csv", cas)) 
      write.csv(gof, file=path1)
      
      gof2 = ssd_gof(dist, pvalue=TRUE)
      path2 = file.path(save_path, sprintf("%s", cas), sprintf("%s_gof_pvalues.csv", cas))
      write.csv(gof2, file=path2)
      
      for (k in c('svg', 'png')) {
        path3 = file.path(save_path, sprintf("%s", cas), sprintf("%s_all_models.%s", cas, k))
        ggsave(filename=path3, plot=all_models_plot, width = 12, height = 7, dpi = 300)
      }
      
      best_fit_model <- subset(gof, subset=delta==0.0)$dist
      distrn <- dist
      outputs <- list('out1' = best_fit_model, 'out2' = distrn)
      return(outputs)
    },
    error = function(e) {
      print("Following error encountered for either ssd_fit_dists or ssd_plot_cdf in the plot_allmodels() function")
      print(e)
      print('===End line')
    }
  )
}


# This function plots and exports fits for average model
plot_averagemodel <- function(df, df_fitted, cas, cname, lbls) {
  
  tryCatch (
      expr = {
        pred <- predict(df_fitted, nboot = 10000, ci = TRUE)
        theme_set(theme_bw())
        
        x_label = sprintf('Concentration of %s (equivalent ppm)', cname)
        average_model_plot <- ssd_plot(df, pred, left = 'Conc', label = 'Latin.Name', color = NULL, hc = 0.05, ci = TRUE, shift_x = 1.3, xlab = x_label, ylab = 'Percent of Species Affected', ribbon = TRUE, shape = NULL, label_size = lbls
        ) +
          ggtitle('') +
          expand_limits(x = 3000) +
          scale_colour_ssd()
        
        for (k in c('svg', 'png')) {
          path_ext1 = file.path(save_path, sprintf("%s", cas), sprintf("%s_average_model.%s", cas, k))
          ggsave(path_ext1, plot=average_model_plot, width = 12, height = 7, dpi = 300)
        }
        },
        error = function(e) {
        print("Following error encountered for either predict or ssd_plot in the plot_averagemodel() function")
        print(e)
        print('===End line')
    }
  )
}


# This function exports the HC05 values and associated standard deviation and confidence limits
get_hc05_data <- function(df_fitted, cas) {
  
  tryCatch(
    expr = {
      hc5_data <- rbind(ssd_hc(df_fitted, proportion = 0.05, ci = TRUE, nboot = 10000),
                        ssd_hc(df_fitted, proportion = 0.05, ci = TRUE, average=FALSE, nboot = 10000, delta = Inf))
      
      path_ext2 = file.path(save_path, sprintf("%s", cas), sprintf("%s_hc5_data.csv", cas))
      write.csv(hc5_data, file=path_ext2)
    },
    error = function(e) {
      print("Following error encountered for ssd_hc in the get_hc05_data() function")
      print(e)
      print('===End line')
    }
  )
}


# This function plots and exports fits for best fit model 
plot_bestfit <- function(bfit, df, cas, cname, lbls) {
  
  tryCatch(
    expr = {
      dist1 <- ssd_fit_dists(df, left = 'Conc', dists = c(bfit), reweight = FALSE, min_pmix = 0, nrow = 5L, computable = TRUE, rescale = FALSE)
      pred1 <- predict(dist1, nboot = 10000, ci = TRUE)
      theme_set(theme_bw())
      
      x_label = sprintf('Concentration of %s (equivalent ppm)', cname)
      best_fit_model <- ssd_plot(df, pred1, left = 'Conc', label = 'Latin.Name', color = NULL, shape = NULL, hc = 0.05, ci = TRUE, shift_x = 1.3, xlab = x_label, ylab = 'Percent of Species Affected', ribbon = TRUE, label_size = lbls
      ) +
        ggtitle('') +
        expand_limits(x = 3000) +
        scale_colour_ssd()
      
      for (k in c('svg', 'png')) {
        path_ext4 = file.path(save_path, sprintf("%s", cas), sprintf("%s_bestfit_model.%s", cas, k))
        ggsave(path_ext4, plot=best_fit_model, width = 12, height = 7, dpi = 300)
      }
      },
      error = function(e) {
        print("Following error encountered for either ssd_fit_dists or predict or ssd_plot in the plot_bestfit() function")
        print(e)
        print('===End line')
      }
    )
}

# function to decide label sizes for the species names in the plot
label_size_fn <- function(cas, chem_df) {
  # obtain the number of species associated with the chemical  
  num_species = subset(chem_df, subset=Chemical==cas)$Species
  if (num_species >= 100) {
    label_size = 0
  } else if (num_species >=80 && num_species < 100) {
    label_size = 0.95
  } else if (num_species >=20 && num_species < 80) {
    label_size = 1.3
  } else {
    label_size = 2.3
  }
  outputs <- list("out1"=num_species, "out2"=label_size)
  return(outputs)
}


################################################################################
# ACUTE SSDS
# set of chemicals for acute SSD construction
ssd_chemicals_acute = subset(x=ssd_chemicals, subset = Type=='Acute')

# extract their CAS
acute_chemicals = ssd_chemicals_acute$Chemical
print(sprintf("Number of CAS ids: %s", length(acute_chemicals)))
print("Top five chemical CAS")
print(acute_chemicals[1:5])

# extract their names
acute_chemicals_names = ssd_chemicals_acute$Chemical_name
print(sprintf("Number of chemicals names: %s", length(acute_chemicals_names)))
print("Top five chemicals' names")
print(acute_chemicals_names[1:5])



# number of chemicals
loop_iter = length(acute_chemicals)
# loop_iter = length(temp_chemicals)
print(sprintf("Number of iterations: %s", loop_iter))


# confirm the number of cores assigned 
# returns number of logical workers (twice of the physical workers assigned)
print(sprintf("Number of cores being used: %s", nbrOfWorkers()))


################################################################################
# MAIN FUNCTION
# To run other functions in a parallel manner
start_time_total <- Sys.time()

temp_log <- NULL

output_df <- foreach(i = 1:loop_iter, 
                     .options.future = list(
                       packages = c("ssdtools", "ggplot2"),
                       seed = TRUE),
                     .inorder=TRUE) %dofuture% {
                       
   # for creating a log file specific to each chemical
   temp_log <- c(sprintf("Constructing SSD for %s", acute_chemicals[i]))
   
   # for timing the speed
   start_time <- Sys.time()
   
   # read the dataframe
   df_path <- file.path(home, "ssd_input", "acute", sprintf("%s.csv", acute_chemicals[i]))
   df <- read.csv(df_path)
   colnames(df) <- make.names(colnames(df))
   temp_log <- c(temp_log, sprintf("Input file read"))
   
   # create folder for the chemical
   if (!dir.exists(file.path(save_path, sprintf("%s", acute_chemicals[i])))) {
     dir.create(file.path(save_path, sprintf("%s", acute_chemicals[i])))
   }
   temp_log <- c(temp_log, sprintf("Folder creation complete"))
   
   
   # determine the label size for species names based on the number of species
   lbl <- label_size_fn(acute_chemicals[i], ssd_chemicals_acute)
   num_species <- lbl$out1
   lbl_size <- lbl$out2
   temp_log <- c(temp_log, sprintf("Number of associated species with this chemical: %s", num_species))
   
   
   # get best fit model name and the fitting parameters for other models
   chem_all_models <- plot_allmodels(df, cas=acute_chemicals[i], cname=acute_chemicals_names[i], lbls = lbl_size)
   
   if (is.null(chem_all_models)) {
     temp_log <- c(temp_log, sprintf("Skipping %s: plot_allmodels failed", acute_chemicals[i]))
     log_file <- file.path(save_path, sprintf("%s", acute_chemicals[i]), sprintf("log_file_acute_SSDs_%s.txt", acute_chemicals[i]))
     writeLines(temp_log, log_file)
     return(data.frame(chemical=acute_chemicals[i], execution_time=NA))
   }
   
   bfit <- chem_all_models$out1
   df_fits <- chem_all_models$out2
   temp_log <- c(temp_log, sprintf("All models fit generated and plots saved"))
   
   # plot average model and save the figures
   plot_averagemodel(df, df_fits, cas=acute_chemicals[i], cname=acute_chemicals_names[i],lbls = lbl_size)
   temp_log <- c(temp_log, sprintf("Averaged model plots generated and saved"))
   
   # extract and save HC05 data
   get_hc05_data(df_fits, cas=acute_chemicals[i])
   temp_log <- c(temp_log, sprintf("HC05 data generated and saved"))
   
   # plot best fit model
   plot_bestfit(bfit, df, cas=acute_chemicals[i], cname=acute_chemicals_names[i], lbls = lbl_size)
   temp_log <- c(temp_log, sprintf("Best-fit model plots generated and saved"))
   
   diff_time <- difftime(Sys.time(), start_time, units = "mins")
   temp_log <- c(temp_log, sprintf(sprintf("SSD construction complete for %s with an execution time (in mins) of %s",acute_chemicals[i], diff_time)))
   temp_log <- c(temp_log, sprintf("==============================="))
   
   log_file <- file.path(save_path, sprintf("%s", acute_chemicals[i]), sprintf("log_file_acute_SSDs_%s.txt", acute_chemicals[i]))
   writeLines(temp_log, log_file)
   
   return(data.frame(chemical=acute_chemicals[i], execution_time=diff_time))
}

# Convert the list to a data frame
combined_output_df <- do.call(rbind, output_df)
print(combined_output_df)
write.csv(combined_output_df, file = file.path(save_path, "execution_time_stats.csv"), row.names = FALSE)


################################################################################
# Close background sessions
plan(sequential)   

# Check the time for the whole code
diff_time_total <- difftime(Sys.time(), start_time_total, units = "mins")
print(sprintf("Execution time for all chemicals (in mins): %s", diff_time_total))

# close the sink
sink()

################################################################################
# END OF CODE