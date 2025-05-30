#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#if _WIN32
#include <windows.h>
#else
#include <pthread.h>
#include <unistd.h>
#endif

#if _WIN32
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT
#endif

FFI_PLUGIN_EXPORT struct Data
{
    long long ts;
    int hr;
    int ox;
    // Add other properties here
};

FFI_PLUGIN_EXPORT struct SleepTimePeriod
{
    long long startTime;
    long long endTime;
    // Add other properties here
};

FFI_PLUGIN_EXPORT struct SleepArrayElement
{
    int data;
    struct SleepTimePeriod sleepTimePeriod;
    struct SleepArrayElement *next;
};

FFI_PLUGIN_EXPORT struct RespiratoryRateResult
{
    struct SleepArrayElement timeSlot;
    double respiratoryRate;
};

FFI_PLUGIN_EXPORT struct HeartRateImmersionResult
{
    long long ts;
    double restingHeartRate;
};

FFI_PLUGIN_EXPORT struct OxygenSaturationResult
{
    int oxygen;
    long long startTime;
    long long endTime;
};

typedef enum
{
    ENUM_SLEEP_STAGING_TYPE_NONE = 0,
    ENUM_SLEEP_STAGING_TYPE_WAKE,
    ENUM_SLEEP_STAGING_TYPE_NREM1,
    ENUM_SLEEP_STAGING_TYPE_NREM3,
    ENUM_SLEEP_STAGING_TYPE_REM,
    ENUM_SLEEP_STAGING_TYPE_NAP
} sleep_type_t;

typedef struct _each_activity
{
    sleep_type_t type;
    long long begin;
    long long end;
} each_activity_t;

typedef struct _act_smy
{
    long long begin;
    long long end;
    double avg_hr;
    int cnt_acts;
    each_activity_t *act_list;
} activity_summary_t;

typedef struct _slp_root
{
    double avg_hr;
    double resting_hr;
    int count;
    activity_summary_t *summaries;
} sleep_root;

typedef struct _hr
{
    // 时间戳，毫秒
    long long ts;
    // 运动数据
    int motion;
    // 心率
    int rate;
    // 变异性
    int hrv;
    // 步数
    int steps;
} smp_hr_t;

typedef struct _csem_sleep
{
    long long ts;
    int awake_order;
    /*
    0: sleep
    1: wake
     */
    int type;
    long bed_rest_duration;
} csem_sleep_t;

typedef struct
{
    long long timeStamp;
    int heartRate;
    int motionDetectionCount;
    int detectionMode;
    int wearStatus;
    int chargeStatus;
    int uuid;
    int hrv;
    int temperature;
    int step;
    int reStep;
    int ox;
    int respiratoryRate;
} HistoryData;

FFI_PLUGIN_EXPORT int aes128_decrypt(char *sn,
                                     size_t sn_size,
                                     char *company,
                                     size_t company_size,
                                     char *data,
                                     size_t data_size,
                                     char *out);

FFI_PLUGIN_EXPORT int toBatteryLevel(int voltage, bool charging, bool wireless);

FFI_PLUGIN_EXPORT struct OxygenSaturationResult *oxygenSaturation(struct SleepArrayElement **sleepArray, int sleepArraySize, struct Data **historyArray, int historyArraySize, int *resultSize);

FFI_PLUGIN_EXPORT struct SleepArrayElement *createSleepArrayElement(int data, long long startTime, long long endTime);
FFI_PLUGIN_EXPORT struct Data *createDataArrayElement(long long ts, int hr, int ox);
FFI_PLUGIN_EXPORT struct HeartRateImmersionResult *heartRateImmersion(struct SleepArrayElement **sleepArray, int sleepArraySize, struct Data **historyArray, int historyArraySize, struct Data **hrArray, int hrArraySize, int *resultSize);
FFI_PLUGIN_EXPORT struct RespiratoryRateResult *respiratoryRate(struct SleepArrayElement **sleepArray, int sleepArraySize, struct Data **historyArray, int historyArraySize, int *resultSize);
FFI_PLUGIN_EXPORT char *formatDateTime(long long inputTime, int isFull);
FFI_PLUGIN_EXPORT double caloriesCalculation(double height, int step, double strengthGrade);
FFI_PLUGIN_EXPORT struct Data **restingHeartRate(struct Data **datas, int dataSize, int *resultSize);
FFI_PLUGIN_EXPORT void v3_calc(smp_hr_t *hr_list, size_t len, sleep_root **root);
FFI_PLUGIN_EXPORT void csem_calc(uint8_t fusion, uint8_t use_hr_only, csem_sleep_t *csem_slps, size_t slp_len, smp_hr_t *hr_list,
                                 size_t hr_len, sleep_root **root);
FFI_PLUGIN_EXPORT void free_activities(sleep_root *ba);
FFI_PLUGIN_EXPORT void timeRepair(HistoryData *arr, int length);
