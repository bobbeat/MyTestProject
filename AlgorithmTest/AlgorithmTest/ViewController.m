//
//  ViewController.m
//  AlgorithmTest
//
//  Created by gaozhimin on 15/3/26.
//  Copyright (c) 2015年 autonavi. All rights reserved.
//

#import "ViewController.h"
#define max1 10000
int distance_poi[7][7] =
{
    0,7,3,max1,max1,max1,max1,
    7,0,3,5,max1,max1,max1,
    3,3,0,3,4,max1,max1,
    max1,5,3,0,2,3,max1,
    max1,max1,4,2,0,5,4,
    max1,max1,max1,3,5,0,3,
    max1,max1,max1,max1,4,3,0
};

int d[7] = {0};
int flag[7] = {0};

@interface MyPoi : NSObject

@property (nonatomic,assign) MyPoi *superPoi;
@property (nonatomic,assign) int poiId;
@property (nonatomic,assign) int distance;
@property (nonatomic,assign) NSMutableArray *edgeArray; //关联的边

@end

@implementation MyPoi

@synthesize superPoi,poiId,distance,edgeArray;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.distance = max1;
        self.edgeArray = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    self.edgeArray = nil;
}


@end

@interface EdgeClass : NSObject

@property (nonatomic,assign) MyPoi *startPoi;
@property (nonatomic,assign) MyPoi *endPoi;
@property (nonatomic,assign) int length;
@end

@implementation EdgeClass

@synthesize startPoi,endPoi,length;

@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self calFun];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//int a[1000][1000];
//int d[1000];//d表示某特定边距离
//int p[1000];//p表示永久边距离
//int i,j,k;
//int m;//m代表边数
//int n;//n代表点数

- (int)calFun
{
    int select = 0;
    for (int i = 1; i < 7; i++)
    {
        d[i] = distance_poi[0][i];
    }
    for (int i = 0; i < 7; i++)
    {
        
        int min = max1;
        for (int j = 0; j < 7; j++)
        {
            if (flag[j] == 0 )
            {
                if (d[j] < min)
                {
                    select = j;
                    min = d[j];
                }
            }
        }
        flag[select] = 1;
        for (int j = 0; j < 7; j++)
        {
            if (flag[j] == 0 && (d[select] + distance_poi[select][j]) < d[j])
            {
                d[j] = d[select] + distance_poi[select][j];
                
            }
        }
    }
    [self calFunOpenAndClose];
    return 0;
}


- (int)calFunOpenAndClose
{
    NSMutableArray *openlist = nil;
    NSMutableArray *closelist = nil;
    NSMutableArray *edgeList = nil;
    NSMutableArray *poiList = nil;
    if (openlist == nil)
    {
        openlist = [[NSMutableArray alloc] init];
        closelist = [[NSMutableArray alloc] init];
        edgeList = [[NSMutableArray alloc] init];
        poiList = [[NSMutableArray alloc] init];
    }
    for (int i = 0; i < 7; i++)
    {
        MyPoi *point = [[MyPoi alloc] init];
        point.poiId = i;
        [poiList addObject:point];
    }
    
    for (int i = 0; i < 7; i++)
    {
        for (int j = i + 1; j < 7; j++)
        {
            if (distance_poi[i][j] < max1)
            {
                EdgeClass *edge = [[EdgeClass alloc] init];
                edge.startPoi = [poiList objectAtIndex:i];;
                edge.endPoi = [poiList objectAtIndex:j];;
                edge.length = distance_poi[i][j];
                
                [edgeList addObject:edge];
            }
        }
    }
    
    for (int i = 1; i < 7; i++) // 访问路网中距离起始点最近且没有被检查过的点，把这个点放入OPEN组中等待检查。
    {
        if (distance_poi[0][i] < max1)
        {
            MyPoi *poi = [poiList objectAtIndex:i];
            poi.distance = distance_poi[0][i];
            [openlist addObject:poi];
            poi.superPoi = [poiList objectAtIndex:0];
        }
    }
    [closelist addObject:[poiList objectAtIndex:0]];
    
    while ([openlist count] > 0)
    {
        MyPoi *currentPoi = nil;
        int min = max1;
        for (MyPoi *openPoi in openlist) //从OPEN表中找出距起始点最近的点，找出这个点的所有子节点，把这个点放到CLOSE表中。
        {
            if (min > openPoi.distance)
            {
                min = openPoi.distance;
                currentPoi = [poiList objectAtIndex:openPoi.poiId];
            }
        }
        [closelist addObject:currentPoi];
        
        for (EdgeClass *edge in edgeList) //遍历考察这个点的子节点。求出这些子节点距起始点的距离值，放子节点到OPEN表中。
        {
            if (edge.startPoi.poiId == currentPoi.poiId)
            {
                MyPoi *endPoi = [poiList objectAtIndex:edge.endPoi.poiId];
                if (endPoi.distance > currentPoi.distance + edge.length)
                {
                    endPoi.superPoi = currentPoi;
                    endPoi.distance = currentPoi.distance + edge.length;
                }
                [openlist addObject:endPoi];
            }
        }
        [openlist removeObject:currentPoi];
    }
    return 0;
}

#define MAX11 1000000
int arcs[10][10];//邻接矩阵
int D[10];//保存最短路径长度
int p[10][10];//路径
int final[10];//若final[i] = 1则说明 顶点vi已在集合S中
int n = 0;//顶点个数
int v0 = 0;//源点
int v,w;

void ShortestPath_DIJ()
{
    for (v = 0; v < n; v++) //循环 初始化
    {
        final[v] = 0; D[v] = arcs[v0][v];
        for (w = 0; w < n; w++) p[v][w] = 0;//设空路径
        if (D[v] < MAX11) {p[v][v0] = 1; p[v][v] = 1;}
    }
    D[v0] = 0; final[v0]=0; //初始化 v0顶点属于集合S
    //开始主循环 每次求得v0到某个顶点v的最短路径 并加v到集合S中
    for (int i = 1; i < n; i++)
    {
        int min = MAX11;
        for (w = 0; w < n; w++)
        {
            //我认为的核心过程--选点
            if (!final[w]) //如果w顶点在V-S中
            {
                //这个过程最终选出的点 应该是选出当前V-S中与S有关联边
                //且权值最小的顶点 书上描述为 当前离V0最近的点
                if (D[w] < min) {v = w; min = D[w];}
            }
        }
        final[v] = 1; //选出该点后加入到合集S中
        for (w = 0; w < n; w++)//更新当前最短路径和距离
        {
            /*在此循环中 v为当前刚选入集合S中的点
             则以点V为中间点 考察 d0v+dvw 是否小于 D[w] 如果小于 则更新
             比如加进点 3 则若要考察 D[5] 是否要更新 就 判断 d(v0-v3) + d(v3-v5) 的和是否小于D[5]
             */
            if (!final[w] && (min+arcs[v][w]<D[w]))
            {
                D[w] = min + arcs[v][w];
                // p[w] = p[v];
                p[w][w] = 1; //p[w] = p[v] +　[w]
            }
        }
    }
}


@end
