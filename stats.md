# Sample Statistics of Each Step in the Pipeline

## 1. Demultiplexing
Test data (options `-l h_data=16g,h_rt=48:00:00,highp -pe shared 2`):
 * User Time: 1:21:03:12
 * System Time: 00:28:25
 * Wallclock Time: 22:38:34
 * CPU: 1:21:31:37
 * Max vmem: 7.030G

## 2. Trimming
Test data (options: `-l h_data=4G,h_rt=2:00:00 -pe shared 4`):
 * User Time        = 05:19:24
 * System Time      = 00:08:04
 * Wallclock Time   = 00:21:54
 * CPU              = 05:27:29
 * Max vmem         = 25.011G

## 3. Quality Control (FastQC)

## 4. Mapping
### Building Index
Test data (options: `-l h_rt=1:00:00,h_data=4G -pe shared 4`):
 * User Time        = 01:27:28
 * System Time      = 00:01:28
 * Wallclock Time   = 00:26:07
 * CPU              = 01:28:57
 * Max vmem         = 5.881G
 ### Mapping
 Test data (options: `-l h_data=5G,h_rt=4:00:00 -pe shared 4`):
 * User Time        = 04:08:43
 * System Time      = 00:32:28
 * Wallclock Time   = 01:17:18
 * CPU              = 05:04:10
 * Max vmem         = 4.518G

## 5. Merging
 Test data (`-l h_data=4G,h_rt=4:00:00 -pe shared 4`):
 * User Time        = 04:50:12
 * System Time      = 00:23:29
 * Wallclock Time   = 01:27:11
 * CPU              = 05:13:42
 * Max vmem         = 45.443G

## 6. Counting
Test data (`-l h_data=6G,h_rt=3:30:00 -pe shared 8`):
 * User Time        = 12:02:04
 * System Time      = 00:06:16
 * Wallclock Time   = 02:22:55
 * CPU              = 12:08:20
 * Max vmem         = 5.428G