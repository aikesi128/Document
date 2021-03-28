###  1. 介绍

HealthKit是苹果提供的一个框架, 用来访问和分享健康和健身数据, HealthKit为健康和健身数据提供了一个中心仓库,  在用户授权后, app可以通过HealthKit store 访问分享这些数据.  HealthKit 提供了大量的数据类型和单位, 用不不允许自己创建数据类型和单位,



### 2. HealthKit 数据

1. 特征数据(**Characteristic data**), 如生日, 血型, 皮肤, 生物性别等, 用户可以直接读取, 但是输入的话必须在健康app中.
2. 样本数据(**Sample data**), 大多数的用户健康数据都是通过样本数据进行存储的,  所有的样本类都继承自 **HKSample类**, 它又是 **HKObject类**的子类
3. 训练数据(**Workout data**):  健身锻炼的数据是通过HKWorkout 进行存储的,  HKWorkout也是HKSample的子类
4. 元数据(**source data**):  每个样本数据都存储关于数据的来源, `HKSourceRevision`对象包含app或设备存储的数据. `HKDevice`对象包含关于产生数据的硬件设备的信息.
5. 删除的对象: `HKDeletedObject` 实例用来暂时存储已经被删除的item的UUID. 当一个数据被用户或者其他app删除, 可以用这个对象响应



### 3.  HKObjects和Sample的属性

`HKObject` 是所有HealthKit sample类型的父类,  'HKObject'的所有子类都是不可变的, 属性如下:

1. UUID: 条目的唯一标识
2. Metadata: 一个字典, 包含该条目的额外信息, 字典可以包含预设和自定义的key, 
3. Source Revision:  sample的来源, 可以是直接把数据存进HealthKit的设备或者app,  HealthKit 自动记录每个对象的来源和版本当一条数据存进来的时候, 这个属性只有当这个对象从healthKit store 中取出来的时候有效
4. Device:  生成数据的硬件设备



所有的HKSample类都是HKObject的子类, 所有的sample类都是HKSample的子类, 属性如下:

1. Type: 样本的类型, 如睡眠分析类型, 身高sample, step count sample.
2. Start date: 样本数据的开始时间
3. End date: 样本数据的结束时间,  如果样本数据仅仅代表一个时间点的数据, 则结束时间应该和开始时间是一样的,  否则, 结束时间应该晚于开始时间



sample 对进一步划分为四个子类

1. Category samples:  可以划分为有限类别的数据
2. Quantity sample:  可以存储为数值类型的数据, 是最长用的数据类型,  他们包括身高, 体重, 步数, 用户的温度, 脉搏速度等等
3. Correlation:  包含一个或者多个sample的复合数据, 在iOS8, HealthKit用这个类型的数据来代表食物, 血压等等, 当你创建食物或者血压数据的时候也应该使用者这个类型
4. Workouts: 训练数据, 代表物理训练, 如跑步, 游泳,  训练数据通常有类型, 时长, 距离, 能量消耗等属性, fine-grained, 你可以将训练数据与一些细粒度的sample关联, 



HealthKit store 是线程安全的, 大多数HealthKit  object是不可变的,  一般情况你可以在多线程环境中使用它

HealthKit的所有回调函数都没有在主线程中执行, 如果你要刷新UI记得切换到主线程



iphone和apple watcch中的数据会自动同步, 为了节省空间, 手表会定期清除旧数据,  iPad没有healthKit



### 4. 配置HealthKit 

1. 在app中允许HealthKit

2. 确保HealthKit在当前手机有效 

   ```
   if (HKHealthStore.isHealthDataAvailable) {
           self.store = [[HKHealthStore alloc]init];;
       }else {
           NSLog(@"aikesi--当前设备不支持HealthKit");
       }
   ```

   

3. 创建自己的HealthKit store

4. 请求授权读写数据



为了保护用户隐私, HealthKit要求对每种数据类型,app必须要申请细粒度的授权, 但是可以不用一次申请完, 要用的时候申请也是可以的



```
let allTypes = Set([HKObjectType.workoutType(),
                    HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                    HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
                    HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                    HKObjectType.quantityType(forIdentifier: .heartRate)!])

healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
    if !success {
        // Handle the error here.
    }
}
```







