	[[SKPaymentQueue defaultQueue] addTransactionObserver:self];

1. 因为自动订阅，除了第一次购买行为是用户主动触发的。后续续费都是Apple自动完成的，一般在要过期的前24小时开始，苹果会尝试扣费，扣费成功的话 会在APP下次启动的时候主动推送给APP。所以，APP启动的时候一定要添加上面的那句话。