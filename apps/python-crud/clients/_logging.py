import structlog
from _env import APP_ENVIRONMENT, LOG_LEVEL

structlog.configure(
    processors=[
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.add_log_level,
        structlog.processors.LogfmtRenderer(key_order=["timestamp", "level", "event"]),
    ] if APP_ENVIRONMENT == 'development' else [
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.add_log_level,
        structlog.processors.JSONRenderer(),
    ],
    wrapper_class=structlog.make_filtering_bound_logger(LOG_LEVEL)
)

logger = structlog.get_logger()
