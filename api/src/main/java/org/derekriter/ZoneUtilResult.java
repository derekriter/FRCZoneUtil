package org.derekriter;

public class ZoneUtilResult<T> {
    public enum Type {
        SUCCESS,
        WARNING,
        ERROR
    }
    public enum Result {
        SUCCESS() {
            @Override
            public Type getType() {
                return Type.SUCCESS;
            }
        },
        JSON_PARSE_WARNING() {
            @Override
            public Type getType() {
                return Type.WARNING;
            }
        },
        FILE_NOT_FOUND_ERROR() {
            @Override
            public Type getType() {
                return Type.ERROR;
            }
        },
        JSON_PARSE_ERROR() {
            @Override
            public Type getType() {
                return Type.ERROR;
            }
        },
        NULL_QUERY_ERROR() {
            @Override
            public Type getType() {
                return Type.ERROR;
            }
        };

        public abstract Type getType();
    }

    private final Result result;
    private final T data;

    public ZoneUtilResult(Result _result, T _data) {
        this.result = _result;
        this.data = _data;
    }

    public Result getResult() {
        return result;
    }

    public boolean isSuccess() {
        return result.getType() == Type.SUCCESS;
    }
    public boolean isWarning() {
        return result.getType() == Type.WARNING;
    }
    public boolean isError() {
        return result.getType() == Type.ERROR;
    }
    public Type getType() {
        return result.getType();
    }

    public T getData() {
        return data;
    }
}
