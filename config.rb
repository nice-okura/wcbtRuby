SHORT = "short"
LONG = "long"

PROC_NUM = 4 # 4 or 8
REQ_EXE_MAX = 5
REQ_EXE_MIN = 1
TASK_EXE_MAX = 20
PRIORITY_MAX = 8
REQ_NUM = 1
TASK_NUM = PROC_NUM == 4 ? 20 : 40
SHORT_GRP_COUNT = 6*TASK_NUM/PROC_NUM
LONG_REQ_COUNT = 8
TASK_FILE_NAME = "./task.json"
REQ_FILE_NAME = "./req.json"
GRP_FILE_NAME = "./grp.json"
NEST_FLG = FALSE

TASK_COUNT = 10
REQ_COUNT = 10
GRP_COUNT = 10
$COLOR_CHAR = true
$DEBUGFlg = false

# preemptive spinにする場合
$PREEMPTIVE_FLG = false

# local resource 考慮
$REMOTE_RESOURCE_FLG = false

# タスク生成ルールを細かく設定する場合．create_task_arrayで使われる
CREATE_MANUALLY  = "create_manually"
SCHE_CHECK = "sche_check"
MY_SCHE_CHECK = "my_sche_check"

# 割り当てモード
WORST_FIT = 1
LIST_ORDER = 2
ID_ORDER = 3
RANDOM_ORDER = 4

# プロセッサ内タスクソート
# Processor.sort_tasks で使用
SORT_PRIORITY = 1
SORT_ID = 2
SORT_UTIL = 3
SORT_PERIOD = 4

PROC_ID_SYN = "proc_id"
TASK_LIST_SYN = "task_list"
UNASSIGNED = -1

# 優先度割付け
# TaskManager.create_task_array の CREATE_MANUALY で使う
PRIORITY_BY_ID = 0  # 標準
PRIORITY_BY_UTIL = 1
PRIORITY_BY_PERIOD = 2
