#include <iostream>
#include "other/options.h"
#include "other/strutil.h"
#include "src/KMeans.h"
#include "src/KMeansCenterMeanEuclid.h"
#include "src/KMeansCenterMeanPearson.h"
#include "src/KMeansCenterMeanSpearman.h"

using namespace std;

const int OPT_DEFS = 8;
const char *c_opt_defaults[OPT_DEFS] = {
        "with_header", "1",
        "max_iter", "40",
        "min_delta", "0.0001",
        "allow_nas", "0"
};


int main(int argc, char *argv[]) {
    options opt;
    opt.load_defaults(c_opt_defaults, OPT_DEFS);
    opt.parse_argv(argc, argv);

    if (argc < 3) {
        cerr << "usage TGLKMeans data k metric -with_header=1\n";
        exit(1);
    }

    //read matrix
    vector<vector<float> > data;
    vector<string> row_names;

    ifstream data_tab(argv[1]);

    read_float_table_with_rowname(data_tab, data, row_names, opt.get_g_int("with_header"), opt.get_g_int("allow_nas"),
                                  REAL_MAX);
    cerr << "data size:" << data.size() << "\n";

    if (data.size() == 0) {
        cerr << "parsed an empty matrix from " << argv[1] << endl;
        exit(0);
    }

    int dim = data[0].size();

    int k = atoi(argv[2]);
    vector<KMeansCenterBase *> centers(k);

    if (string(argv[3]) == "euclid") {
        for (int i = 0; i < k; i++) {
            centers[i] = new KMeansCenterMeanEuclid(dim);
        }
    } else if (string(argv[3]) == "pearson") {
        for (int i = 0; i < k; i++) {
            centers[i] = new KMeansCenterMeanPearson(dim);
        }
    } else if (string(argv[3]) == "spearman") {
        for (int i = 0; i < k; i++) {
            centers[i] = new KMeansCenterMeanSpearman(dim);
        }
    } else {
        cerr << "cannot match metric name";
        return 0;
    }

    KMeans kmeans(data, k, centers);

    kmeans.cluster(opt.get_g_int("max_iter"), opt.get_g_float("min_delta"));
    string centers_fn = string(argv[1]) + ".center";
    string assign_fn = string(argv[1]) + ".kclust";
    ofstream centers_tab(centers_fn.c_str());
    ofstream assignment_tab(assign_fn.c_str());

    kmeans.report_centers(centers_tab);
    kmeans.report_assignment(row_names, assignment_tab);

    return 0;
    }

//    options opt;
//    opt.load_defaults(c_opt_defaults, OPT_DEFS);
//    opt.parse_argv(argc, argv);
//
//    if(argc < 3) {
//        cerr << "usage TGLKMeans data k metric -with_header=1\n";
//        exit(1);
//    }
//
//    //read matrix
//    vector<vector<float> > data;
//    vector<string> row_names;
//
//    ifstream data_tab(argv[1]);
//    ASSERT(data_tab,"cannot open data tab " << argv[1]);
//
//    read_float_table_with_rowname(data_tab, data, row_names, opt.get_g_int("with_header"), opt.get_g_int("allow_nas"), REAL_MAX);
//    cerr<<"data size:"<<data.size()<<"\n";
//
//    if(data.size() == 0) {
//        cerr << "parsed an empty matrix from " << argv[1] << endl;
//        exit(0);
//    }
//
//    int dim = data[0].size();
//
//    int k = atoi(argv[2]);
//    vector<KMeansCenterBase *> centers(k);
//
//    if(string(argv[3]) == "euclid") {
//        for(int i = 0; i < k; i++) {
//            centers[i] = new KMeansCenterMeanEuclid(dim);
//        }
//    } else if(string(argv[3]) == "pearson") {
//        for(int i = 0; i < k; i++) {
//            centers[i] = new KMeansCenterMeanEuclid(dim);
//        }
//    } else if(string(argv[3]) == "spearman") {
//        for(int i = 0; i < k; i++) {
//            centers[i] = new KMeansCenterMeanSpearman(dim);
//        }
//    } else if(string(argv[3]) == "spatsym" || string(argv[3]) == "padded") {
//        int section_size = opt.get_g_int("section_size");
//
//        PairDistFuncBase *pairdist;
//
//
//        int with_na = opt.get_g_int("allow_nas");
//        if(opt.get_g_str("sub_metric") == "spearman") {
//            if(with_na) {
//                ASSERT(0, "Spearman distance with allow_nas=1 is not currently supported\n");
//            }
//            pairdist = new PairDistFuncSpearman;
//        } else if(opt.get_g_str("sub_metric") == "euclid") {
//            if(with_na) {
//                pairdist = new PairDistFuncNorm2NAMAX;
//            } else {
//                pairdist = new PairDistFuncNorm2;
//            }
//        } else if(opt.get_g_str("sub_metric") == "norm1") {
//            if(with_na) {
//                pairdist = new PairDistFuncNorm1NAMAX;
//            } else {
//                pairdist = new PairDistFuncNorm1;
//            }
//        } else if(opt.get_g_str("sub_metric") == "pearson") {
//            if(with_na) {
//                pairdist = new PairDistFuncPearsonNAMAX;
//            } else {
//                pairdist = new PairDistFuncPearson;
//            }
//        }
//
//        for(int i = 0; i < k; i++) {
//            if (string(argv[3]) == "spatsym"){
//                centers[i] = new KMeansCenterMeanSpatSym(dim, section_size, pairdist);
//            }
//            else if (string(argv[3]) == "padded"){
//                centers[i] = new KMeansCenterMeanPadded(dim, section_size, pairdist,opt.get_g_int("padding_size"));
//            }
//        }
//    } else {
//        ASSERT(0, "db/tracks/wiaux/5mc_c3_96_normcannot match metric name " << argv[3]);
//    }
//    KMeans kmeans(data, k, centers);
//
//    kmeans.cluster(opt.get_g_int("max_iter"), opt.get_g_float("min_delta"));
//    string centers_fn = string(argv[1]) + ".center";
//    string assign_fn = string(argv[1]) + ".kclust";
//    ofstream centers_tab(centers_fn.c_str());
//    ofstream assignment_tab(assign_fn.c_str());
//
//    kmeans.report_centers(centers_tab);
//    kmeans.report_assignment(row_names, assignment_tab);
//}


