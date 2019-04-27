package com.example.bradycardia;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.widget.Spinner;
import android.widget.Button;
import android.widget.AdapterView;
import android.view.View;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import butterknife.OnItemSelected;
import butterknife.internal.Utils;

public class MainActivity extends AppCompatActivity {

    @BindView(R.id.patient_spinner)
    Spinner patient_spinner;

    @BindView(R.id.model_spinner)
    Spinner model_spinner;

    @BindView(R.id.classify_button)
    Button classify_button;

    @BindView(R.id.predict_button)
    Button predict_button;

    String patient;
    String model;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        //classify_button.setVisibility(View.GONE);
        //predict_button.setVisibility(View.GONE);
        ButterKnife.bind(this);

        //Button classify_button = (Button)findViewById(R.id.classify_button);
        //Button predict_button = (Button)findViewById(R.id.predict_button);

        patient_spinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {
                String text = patient_spinner.getSelectedItem().toString();
                Log.d("PatientSpinner:", text);
                patient = text;
            }


            @Override
            public void onNothingSelected(AdapterView<?> adapterView) {

            }
        });

        model_spinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {
                String text = model_spinner.getSelectedItem().toString();
                Log.d("ModelSpinner:", text);
                model = text;
            }


            @Override
            public void onNothingSelected(AdapterView<?> adapterView) {

            }
        });


        classify_button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Log.d("Classify:", "Button clicked");
                Classify(patient, model);
            }
        });

        predict_button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Log.d("Predict:", "Button clicked");
                Predict(patient, model);
            }
        });
    }

    public void Classify(String patient, String model)
    {

    }

    public void Predict(String patient, String model)
    {

    }
}
