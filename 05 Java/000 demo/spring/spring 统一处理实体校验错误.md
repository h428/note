

- 统一处理实体校验异常是通过全局异常处理器来处理指定两个指定的异常来完成的
- 全局异常处理器：类上加 `@ControllerAdvice` 注解，方法上加 `@ExceptionHandler(XxxException.class)` 即可处理对应异常，一个类中可以有多个方法以处理多个异常
- 实体校验出错后主要涉及两个异常：
    - MethodArgumentNotValidException：RequestBody 类的请求校验错误时会抛出该异常
    - BindException：表单类请求校验出错时则抛出该异常
- 因此只要处理上述两类异常的处理即可，代码如下：
```java
@ControllerAdvice
public class GlobalExceptionHandler {

    // RequestBody 类请求会使用该隐藏
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ResBean> handleBindException(MethodArgumentNotValidException ex) {
        FieldError fieldError = ex.getBindingResult().getFieldError();
        return ResBean.badRequest_400(fieldError.getDefaultMessage());
    }

    // 表单类请求会使用该异常
    @ExceptionHandler(BindException.class)
    public ResponseEntity<ResBean> handleBindException(BindException ex) {
        //校验 除了 requestbody 注解方式的参数校验 对应的 bindingresult 为 BeanPropertyBindingResult
        FieldError fieldError = ex.getBindingResult().getFieldError();
        return ResBean.badRequest_400(fieldError.getDefaultMessage());
    }

    // 路径参数绑定异常
    @ExceptionHandler(ConstraintViolationException.class)
    public ResponseEntity<ResBean> handleBindException(ConstraintViolationException ex) {
        ConstraintViolation<?> constraintViolation = ex.getConstraintViolations().iterator().next();
        return ResBean.badRequest_400(constraintViolation.getMessage());
    }
}
```